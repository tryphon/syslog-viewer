LogAccess::Application.instance.tap do |app|
  app.logger = Logger.new "log/development.log"
end
