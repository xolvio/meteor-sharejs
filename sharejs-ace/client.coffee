# Set asset path in Ace config
ace.require('ace/config').set('basePath', '/packages/xolvio_sharejs-ace/ace-builds/src-noconflict')
UndoManager = ace.require('ace/undomanager').UndoManager

class ShareJSAceConnector extends ShareJSConnector
  createView: ->
    return Blaze.With(Blaze.getData, -> Template._sharejsAce)

  rendered: (element) ->
    super
    @ace = ace.edit(element)
    # Configure the editor if specified
    @configCallback?(@ace)

  connect: ->
    @ace.setReadOnly(true); # Disable editing until share is connected
    super

  attach: (doc) ->
    super
    doc.attach_ace(@ace)
    # Reset undo stack, so that we can't undo to an empty document
    # XXX It seems that we should be able to use getUndoManager().reset()
    # here, but that doesn't seem to work:
    # http://japhr.blogspot.com/2012/10/ace-undomanager-and-setvalue.html
    @ace.getSession().setUndoManager(new UndoManager)
    @ace.setReadOnly(false)
    @connectCallback?(@ace)

  disconnect: ->
    # Detach ace editor, if any
    @doc?.detach_ace?()
    super

  destroy: ->
    super
    # Meteor._debug "destroying Ace editor"
    @ace?.destroy()
    @ace = null

UI.registerHelper "sharejsAce", new Template('sharejsAce', ->
  return new ShareJSAceConnector(this).create()
)
