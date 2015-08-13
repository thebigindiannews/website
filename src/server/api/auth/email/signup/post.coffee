Promise   = require "bluebird"
passport  = require "passport"
validator = require "validator"

# Controller for the Registering a user via email
exports = module.exports = (IoC, Email, reCaptcha, Users) ->
  logger = IoC.create "igloo/logger"

  validateRequest = (request) ->
    email = request.body.email
    username = request.body.username
    password = request.body.password

    # Check for any missing fields
    if not password or not email or not username
      throw new Error "missing fields"

    # Check for a short password
    if password.length < 6 then throw new Error "short password"

    # Check for invalid characters
    if not (validator.isEmail email) or
    not (validator.matches username, /[a-zA-Z0-9_]+/)
      throw new Error "bad email/name"

    request


  createNewUserObject = (request) ->
    email: request.body.email
    language: 1 # hard code for now
    login_providers: email: request.body.email
    mailing_list_token: Users.hashPassword Users.randomPassword()
    meta: activationToken: Users.hashPassword Users.randomPassword()
    password: Users.hashPassword request.body.password
    role: Users.roles["Normal"]
    rss_token: Users.hashPassword Users.randomPassword()
    slug: request.body.username
    status: Users.statuses["In-Active"]
    username: request.body.username


  validateWithDBUser = (newUser, dbUser) ->
    # User already exists in database.
    if dbUser
      dbUserJSON = dbUser.toJSON()
      if dbUserJSON.login_providers?

        # User exists and already has been registered with email login.
        if dbUserJSON.login_providers.email
          throw new Error "user already registered with email"
        else dbUserJSON.login_providers.email = newUser.email

        # User exists but does not have email login, so modify the current
        # user. Then save into the DB.
        dbUserJSON.meta ?= {}
        dbUserJSON.meta.newName = newUser.fullname
        dbUserJSON.meta.newPassword = newUser.password
        dbUserJSON.meta.signupVerifyToken = newUser.meta.activationToken
        emailOptions =
          template: "user/signup-modified"
          subject: "Your account has been modified. Verify this!"
          user: dbUser
        [emailOptions, Users.patch dbUserJSON.id, dbUserJSON]

    # If there is no user with that email, create the user
    else
      emailOptions =
        email: newUser.email
        template: "user/signup-activate"
        subject: "#{newUser.full_name}! Activate your account"
        user: newUser
      [emailOptions, Users.create newUser]


  sendEmail = (emailOptions, newUser) ->
    emailOptions.user = newUser.toJSON()
    Email.sendTemplate emailOptions.subject, emailOptions.email,
      emailOptions.template, emailOptions
    newUser


  (request, response, next) ->
    # reCaptcha.verify request
    Promise.resolve request
    .then validateRequest
    .then createNewUserObject
    .then (newUser) -> [newUser, Users.findOne email: newUser.email]
    .spread validateWithDBUser
    .spread sendEmail

    # Once done, return the fields that have been changed back to the user
    .then (result) ->
      request.logIn result, (error) ->
        if error then throw error
        response.json result

    .catch (error) ->
      logger.error    error.stack
      response.status error.status or 400
      response.json   error.message


exports["@require"] = [
  "$container"
  "libraries/email"
  "libraries/recaptcha"

  "models/users"
]
exports["@singleton"] = true
