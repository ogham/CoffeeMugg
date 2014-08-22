HTMLContext = require './html.coffee'

g_context = new HTMLContext({})

module.exports =
  render: (template, options, args...) ->
    g_context.setOptions options if options?
    return g_context.render(template, args...).toString()
  install_plugin: (plugin) ->
    plugin = require(plugin) if typeof plugin is 'string'
    plugin.call(g_context, g_context)
