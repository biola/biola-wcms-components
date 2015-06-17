class GalleryPhotos
  attr_reader :parent
  attr_reader :params

  def initialize(parent, params)
    @parent = parent
    @params = params
  end

  def sort_gallery_photos_for_parent
    params[:gallery_photos].each_with_index do |id, index|
      parent.gallery_photos.find(id).update_attributes(order: index+1)
    end
  end
end
