jQuery ->
  new PosterCropper()

class PosterCropper
  constructor: ->
    $('#event_cropbox').Jcrop
      setSelect: [0,0,150,225]
      bgColor:  'black'
      bgOpacity:   .5
      minSize: [150,225]
      maxSize: [300, 450]
      onSelect: @update
      onChange: @update
      aspectRatio: 0.67 

  update: (coords) =>
    $('#event_crop_x').val(coords.x)
    $('#event_crop_y').val(coords.y)
    $('#event_crop_w').val(coords.w)
    $('#event_crop_h').val(coords.h)
    # @updatePreview(coords)

  updatePreview: (coords) =>
  	$('#preview').css
  		width: Math.round(150/coords.w * $('#cropbox').width()) + 'px'
  		height: Math.round(225/coords.h * $('#cropbox').height()) + 'px'
  		marginLeft: '-' + Math.round(150/coords.w * coords.x) + 'px'
  		marginTop: '-' + Math.round(225/coords.h * coords.y) + 'px'

