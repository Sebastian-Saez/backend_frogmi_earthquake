class FeaturesController < ApplicationController
  before_action :set_feature, only: %i[ show edit update destroy ]

  # GET /features or /features.json
  def index
    puts "INICIO INDEX7"
    fetch_and_store_data
    features = Feature.all
    #render json: FeatureSerializer.new(features).serializable_hash    
    render json: features, each_serializer: FeatureSerializer
  end

  def fetch_and_store_data
    puts "Fetch4===="
    #@features = Feature.all
    url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson'
    connection = Faraday.new(url)
    response = connection.get    
    data = JSON.parse(response.body)

    puts "Resultado DATA.metadata"
    
    #Se recorre la data obtenida para validar si existe y está dentro del rango.
    data['features'].each do |feature_data|
        next if Feature.exists?(external_id: feature_data['id'])
        feature = Feature.new(
          external_id:  feature_data['id'],
          magnitude:    feature_data['properties']['mag'],
          place:        feature_data['properties']['place'],
          time: Time.at(feature_data['properties']['time'] / 1000),
          tsunami:      feature_data['properties']['tsunami'] == 1,
          mag_type:     feature_data['properties']['magType'],
          title:        feature_data['properties']['title'],
          longitude:    feature_data['geometry']['coordinates'][0],
          latitude:     feature_data['geometry']['coordinates'][1]
        )
        if feature.valid?
          feature.save
        end
      end
    #head :no_content
  end

  # GET /features/1 or /features/1.json
  def show
  end

  # GET /features/new
  def new
    @feature = Feature.new
  end

  # GET /features/1/edit
  def edit
  end

  # POST /features or /features.json
  def create
    @feature = Feature.new(feature_params)

    respond_to do |format|
      if @feature.save
        format.html { redirect_to feature_url(@feature), notice: "Feature was successfully created." }
        format.json { render :show, status: :created, location: @feature }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /features/1 or /features/1.json
  def update
    respond_to do |format|
      if @feature.update(feature_params)
        format.html { redirect_to feature_url(@feature), notice: "Feature was successfully updated." }
        format.json { render :show, status: :ok, location: @feature }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feature.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /features/1 or /features/1.json
  def destroy
    @feature.destroy!

    respond_to do |format|
      format.html { redirect_to features_url, notice: "Feature was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feature
      @feature = Feature.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feature_params
      params.require(:feature).permit(:external_id, :magnitude, :place, :time, :tsunami, :mag_type, :title, :longitude, :latitude)
    end
end
