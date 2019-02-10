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
    # Get ratings and sort_by from params, or if they're stored in session, get them
    # from the session and then redirect the request so that they're in params (to be RESTful).
    reload = false
    @ratings =
      if params.key?(:ratings)
        params[:ratings]
      elsif session.key?(:ratings)
        reload = true
        session[:ratings]
      else
        Hash[Movie.all_ratings.collect {|rating| [rating, 1]}]
      end
    @sort_by =
      if params.key?(:sort_by)
        params[:sort_by]
      elsif session.key?(:sort_by)
        reload = true
        session[:sort_by]
      else
        ''
      end

    # If either ratings or sort_by was loaded from session, redirect to URI with specified ratings and sort_by
    if reload
      flash.keep
      redirect_to(movies_path(ratings: @ratings, sort_by: @sort_by))
    else
      # Save ratings and sorting in session
      session[:ratings] = @ratings
      session[:sort_by] = @sort_by

      # Get all possible ratings for movies in the database
      @all_ratings = Movie.all_ratings

      case @sort_by
      when "title"
        @movies = Movie.where({rating: @ratings.keys}).order(:title)
      when "release_date"
        @movies = Movie.where({rating: @ratings.keys}).order(:release_date)
      else
        @movies = Movie.where({rating: @ratings.keys})
      end
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
