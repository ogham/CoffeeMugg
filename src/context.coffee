class Context
  constructor: (@options) ->
    @_buffer = ''
    @_newline = ''
    @_indent = ''

  setOptions: (options) ->
    options.format      ?= on
    options.autoescape  ?= on
    @options = options
    return @

  @NEWLINE = {}

  render: (contents, args...) ->
    if typeof contents is 'string'
      throw Error "Need module 'coffee-script' to compile code." if not coffee?
      eval "contents = function () {#{coffee.compile contents, bare: yes}}"
    @reset()
    if typeof contents is 'function'
      contents.call(this, args...)
    this

  renderTag: (name, args) ->
    # get idclass, attrs, contents
    for a in args
      switch typeof a
        when 'function'
          contents = a.bind(this)
        when 'object'
          attrs = a
        when 'number', 'boolean'
          contents = a
        when 'string'
          if args.length is 1
            contents = a
          else
            if a is args[0]
              idclass = a
            else
              contents = a
    @rawnl "<#{name}"
    @renderIDAndClass(idclass) if idclass
    @renderAttributes(attrs) if attrs
    if @isSelfClosing(name)
      @raw ' />'
    else
      @raw '>'
      escapeContents = name != 'script' # do not escape the contents of a <script> tag.
      @renderContents(contents, escapeContents)
      @raw "</#{name}>"
    Context.NEWLINE

  renderIDAndClass: (str) ->
    classes = []
    str = String(str).replace /"/, "&quot;"
    for i in str.split /\s*\.\s*/
      if i[0] is '#'
        id = i[1..]
      else
        classes.push i unless i is ''
    @raw " id=\"#{id}\"" if id
    @raw " class=\"#{classes.join ' '}\"" if classes.length > 0
    null

  renderAttributes: (obj) ->
    for k, v of obj
      # Hyphenate any camelcase attributes
      k = k.replace(/([A-Z])/g, '-$1').toLowerCase()

      # true is rendered as `selected="selected"`.
      if typeof v is 'boolean' and v
        v = k
      # undefined, false and null result in the attribute not being rendered.
      else if typeof v is 'function'
        v = @csToString v

      if v
        # strings, numbers, objects and arrays are rendered "as is"
        # http://www.w3.org/TR/html4/appendix/notes.html#h-B.3.2.2
        @raw " #{k}=\"#{String(v).replace(/&/g,"&amp;").replace(/"/g,"&quot;")}\""
    null

  renderContents: (contents, escape) ->
    if typeof contents is 'function'
      @_indent += '  ' if @options.format
      contents = contents.call(this)
      @_indent = @_indent[2..] if @options.format
      if contents is Context.NEWLINE
        @rawnl ""
    switch typeof contents
      when 'string', 'number', 'boolean'
        if escape
          @text(contents)
        else
          @raw(contents)
    null

  htmlEscape: (txt) ->
    String(txt).replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')

  h: @::htmlEscape

  rawnl: (txt) ->
    @raw "#{@_newline}#{@_indent}#{txt}"
    @_newline = "\n" if @options.format
    null

  raw: (txt) ->
    @_buffer += txt
    null

  text: (txt) ->
    if @options? && @options.autoescape != false
      @_buffer += @htmlEscape txt
    else
      @_buffer += txt
    null

  tag: (name, args...) ->
    @renderTag(name, args)

  comment: (cmt) ->
    @rawnl "<!--#{cmt}-->"
    Context.NEWLINE

  toString: ->
    @_buffer

  reset: ->
    @_buffer  = ''
    @_newline = ''
    @_indent  = ''
    return @

module.exports = Context
