jQuery ->
  new AvatarCropper()

class AvatarCropper
  constructor: ->
    $('#note_cropbox').Jcrop
      aspectRatio: 1
      setSelect: [0, 0, 130, 130]
      bgColor:  'black'
      bgOpacity:   .5
      minSize: [130, 130]
      maxSize: [280, 280]
      onSelect: @update
      onChange: @update

  update: (coords) =>
    $('#note_crop_x').val(coords.x)
    $('#note_crop_y').val(coords.y)
    $('#note_crop_w').val(coords.w)
    $('#note_crop_h').val(coords.h)
    # @updatePreview(coords)

  updatePreview: (coords) =>
    $('#preview').css
      width: Math.round(50/coords.w * $('#note_cropbox').width()) + 'px'
      height: Math.round(50/coords.h * $('#note_cropbox').height()) + 'px'
      marginLeft: '-' + Math.round(50/coords.w * coords.x) + 'px'
      marginTop: '-' + Math.round(50/coords.h * coords.y) + 'px'
