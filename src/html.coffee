Context = require './context.coffee'

class HTMLContext extends Context
  @doctypes:
    'default': '<!DOCTYPE html>'
    '5': '<!DOCTYPE html>'
    'xml': '<?xml version="1.0" encoding="utf-8" ?>'
    'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
    'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">'
    '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">'
    'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">'
    'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'

  doctype: (type = 'default') ->
    @rawnl HTMLContext.doctypes[type]

  @elements: '''
    a abbr address article aside audio b bdi bdo blockquote body button canvas
    caption cite code colgroup datalist dd del details dfn div dl dt em fieldset
    figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup html i
    iframe ins kbd label legend li map mark menu meter nav noscript object ol
    optgroup option output p pre progress q rp rt ruby s samp script section
    select small span strong style sub summary sup table tbody td textarea tfoot
    th thead time title tr u ul var video
  '''.split /\s+/

  @selfClosings: '''
    area base br col command embed hr img input keygen link meta param
    source track wbr
  '''.split /\s+/

  constructor: (o) ->
    super o
    for tags in [ HTMLContext.elements, HTMLContext.selfClosings ]
      for tag in tags then do (tag) =>
        @[tag] = -> @render_tag(tag, arguments)

  isSelfClosing: (tagName) ->
    tagName in HTMLContext.selfClosings

  ie: (condition, contents) ->
    @rawnl "<!--[if #{condition}]>"
    @render_contents(contents)
    @raw "<![endif]-->"
    Context.NEWLINE

  # CoffeeScript-generated JavaScript may contain anyone of these; but when we
  # take a function to string form to manipulate it, and then recreate it through
  # the `Function()` constructor, it loses access to its parent scope and
  # consequently to any helpers it might need. So we need to reintroduce these
  # inside any "rewritten" function.
  # From coffee-script/lib/coffee-script/nodes.js under UTILITIES
  @coffeescript_helpers:
    __extends: """
      function(child, parent) {
        for (var key in parent) {
          if (__hasProp.call(parent, key)) child[key] = parent[key];
        }
        function ctor() { this.constructor = child; }
        ctor.prototype = parent.prototype;
        child.prototype = new ctor();
        child.__super__ = parent.prototype;
        return child;
      }
    """.replace(/\s+/g, ' ')
    __bind: """
      function(fn, me){
        return function(){ return fn.apply(me, arguments); };
      }
    """.replace(/\s+/g, ' ')
    __indexOf: """
      [].indexOf || function(item) {
        for (var i = 0, l = this.length; i < l; i++) {
          if (i in this && this[i] === item) return i;
        }
        return -1;
      }
    """.replace(/\s+/g, ' ')
    __hasProp: '{}.hasOwnProperty'
    __slice: '[].slice'

  csToString: (aFunction) ->
    helpers = ''
    t = "#{aFunction}"
    for k, v of HTMLContext.coffeescript_helpers
      if t.indexOf(k) >= 0
        helpers += ',' if helpers
        helpers += "#{k}=#{v}"
    t = t.replace(/^[^{]+{/, "function(){var #{helpers};") if helpers
    "(#{t}).call(this);"

  coffeescript: (param) ->
    switch typeof param
      # `coffeescript -> alert 'hi'` becomes:
      # `<script>;(function () {return alert('hi');})();</script>`
      when 'function'
        @script @csToString param
      # `coffeescript "alert 'hi'"` becomes:
      # `<script type="text/coffeescript">alert 'hi'</script>`
      when 'string'
        @script type: 'text/coffeescript', -> param
      # `coffeescript src: 'script.coffee'` becomes:
      # `<script type="text/coffeescript" src="script.coffee"></script>`
      when 'object'
        param.type = 'text/coffeescript'
        @script param

  css_props = '''
    align-content align-items align-self alignment-adjust alignment-baseline
    anchor-point animation animation-delay animation-direction
    animation-duration animation-iteration-count animation-name
    animation-play-state animation-timing-function appearance azimuth
    backface-visibility background background-attachment background-clip
    background-color background-image background-origin background-position
    background-repeat background-size baseline-shift binding bleed
    bookmark-label bookmark-level bookmark-state bookmark-target border
    border-bottom border-bottom-color border-bottom-left-radius
    border-bottom-right-radius border-bottom-style border-bottom-width
    border-collapse border-color border-image border-image-outset
    border-image-repeat border-image-slice border-image-source
    border-image-width border-left border-left-color border-left-style
    border-left-width border-radius border-right border-right-color
    border-right-style border-right-width border-spacing border-style
    border-top border-top-color border-top-left-radius border-top-right-radius
    border-top-style border-top-width border-width bottom box-align
    box-decoration-break box-direction box-flex box-lines box-ordinal-group
    box-orient box-pack box-shadow box-sizing break-after break-before
    break-inside caption-side clear clip color color-profile column-count
    column-fill column-gap column-rule column-rule-color column-rule-style
    column-rule-width column-span column-width columns content counter-increment
    counter-reset crop cue cue-after cue-before cursor direction display
    dominant-baseline drop-initial-after-adjust drop-initial-after-align
    drop-initial-before-adjust drop-initial-before-align drop-initial-size
    drop-initial-value elevation empty-cells fit fit-position flex flex-basis
    flex-direction flex-flow flex-grow flex-shrink flex-wrap float float-offset
    font font-feature-settings font-family font-kerning font-language-override
    font-size font-size-adjust font-stretch font-style font-synthesis
    font-variant font-variant-alternates font-variant-caps
    font-variant-east-asian font-variant-ligatures font-variant-numeric
    font-variant-position font-weight hanging-punctuation height hyphens icon
    image-orientation image-rendering image-resolution inline-box-align
    justify-content left letter-spacing line-break line-height line-stacking
    line-stacking-ruby line-stacking-shift line-stacking-strategy list-style
    list-style-image list-style-position list-style-type margin margin-bottom
    margin-left margin-right margin-top marker-offset marks marquee-direction
    marquee-loop marquee-play-count marquee-speed marquee-style max-height
    max-width min-height min-width move-to nav-down nav-index nav-left nav-right
    nav-up opacity order orphans outline outline-color outline-offset
    outline-style outline-width overflow overflow-style overflow-wrap overflow-x
    overflow-y padding padding-bottom padding-left padding-right padding-top page
    page-break-after page-break-before page-break-inside page-policy pause
    pause-after pause-before perspective perspective-origin pitch pitch-range
    play-during position presentation-level punctuation-trim quotes
    rendering-intent resize rest rest-after rest-before richness right rotation
    rotation-point ruby-align ruby-overhang ruby-position ruby-span size speak
    speak-as speak-header speak-numeral speak-punctuation speech-rate stress
    string-set tab-size table-layout target target-name target-new
    target-position text-align text-align-last text-autospace text-decoration
    text-justify text-overflow text-decoration-color text-decoration-line
    text-decoration-skip text-decoration-style text-emphasis text-emphasis-color
    text-emphasis-position text-emphasis-style text-height text-indent
    text-justify text-outline text-shadow text-space-collapse text-transform
    text-underline-position text-wrap top transform transform-origin
    transform-style transition transition-delay transition-duration
    transition-property transition-timing-function unicode-bidi vertical-align
    visibility voice-balance voice-duration voice-family voice-pitch voice-range
    voice-rate voice-stress voice-volume volume white-space widows width
    word-break word-spacing word-wrap z-index
  '''.split(/\s+/)

  valid_css_prop = {}
  for p in css_props
    valid_css_prop[p] = true

  @_imw: [ "", "ms-", "-moz-", "-webkit-", "" ]

  # See WD or CR at http://peter.sh/experiments/vendor-prefixed-css-property-overview/
  @css_needs_prefix: '''
    animation animation-delay animation-direction animation-duration
    animation-iteration-count animation-name animation-play-state
    animation-timing-function backface-visibility border-bottom-left-radius
    border-bottom-right-radius border-image border-top-left-radius
    border-top-right-radius box-align box-decoration-break box-direction
    box-flex box-lines box-ordinal-group box-sizing column-count column-fill
    column-gap column-rule column-rule-color column-rule-style
    column-rule-width column-span column-width columns filter ime-mode opacity
    overflow-x overflow-y perspective perspective-origin text-align-last
    text-autospace text-justify text-overflow
  '''.split(/\s+/)

  prefixed_css_prop = do =>
    tmp = {}
    for p in HTMLContext.css_needs_prefix
      tmp[p] = true
    tmp

  parse_prop: (prop, val, parent, open) ->
    #  _ to -
    t = prop.replace /_/g, '-'
    prop = t if valid_css_prop[t]

    if typeof val is 'object'
      # subselector
      @rawnl "}" if open
      @parse_selector prop, val, parent
      return no
    else
      # CSS property
      @rawnl "#{parent} {" unless open
      line = "#{prop}: #{val}"
      line += @unit if typeof val is 'number'
      line += ";"
      @rawnl line
      if prefixed_css_prop[prop]
        for pre in [ "ms-", "-moz-", "-webkit-" ]
          @rawnl "#{pre}#{line}"
      return yes

  parse_selector: (selector, obj, parent) ->
    if parent
      # Rewrite our selector using the parent
      selectors = for p in parent.split /\s*,\s*/
        for s in selector.split /\s*,\s*/
          if s.indexOf('&') >= 0
            s.replace /&/g, p
          else
            "#{p} #{s}"
      selector = selectors.join ','

    open = no
    @_indent += '  ' if @options.format
    if obj instanceof Array
      for o in obj then for prop, val of o
        open = @parse_prop prop, val, selector, open
    else if typeof obj is 'object'
      for prop, val of obj
        open = @parse_prop prop, val, selector, open
    else
      throw Error "Don't know what to do with #{obj}"
    @_indent = @_indent[2..] if @options.format
    @rawnl "}" if open

  unit: 'px'
  css: (args...) ->
    for arg in args
      if arg instanceof Array
        for obj in arg
          for k, v of obj
            @parse_selector k, v
      else if typeof arg is 'object'
        for k, v of arg
          @parse_selector k, v
      else
        throw Error "@css takes objects or arrays of objects"
    null

module.exports = HTMLContext
