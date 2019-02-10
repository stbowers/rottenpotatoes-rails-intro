class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Get all possible ratings for movies in the database
    @all_ratings = Movie.all_ratings

    # Get which ratings we should display to the user (all enabled if no ratings params found)
    @display_ratings = params.key?(:ratings) ? params[:ratings].keys : @all_ratings
    
    @sort_by = params.key?(:sort_by) ? params[:sort_by] : ''
    case @sort_by
    when "title"
      @movies = Movie.order(:title)
    when "release_date"
      @movies = Movie.order(:release_date)
    else
      @movies = Movie.where({rating: @display_ratings})
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
