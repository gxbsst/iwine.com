# encoding: utf-8
class NotesController < ApplicationController

  def index
    result  = Notes::NotesRepository.all
    return render_404('') unless result['state']
    @notes =  Notes::HelperMethods.build_all_notes(result)
  end

  def show
   result  = Notes::NotesRepository.find(params[:id])
   return render_404('') unless result['state']

   @note = Notes::NoteItem.new(result['data'])
   @user       = User.find(result['data']['uid'])
   notes_result = Notes::NotesRepository.find_by_user(result['data']['uid'], @note.note.id)
   @user_notes = Notes::HelperMethods.build_user_notes(notes_result)  if notes_result['state']

   wine_result =  Notes::NotesRepository.find_by_wine(@note.wine.vintage, @note.wine.sName, @note.wine.oName, @note.note.id)
   @wine_note_users = Notes::HelperMethods.build_wine_notes(wine_result)  if wine_result['state']
  end

  def trait
    @categories = WineTrait.where(:parent_id => 0)
    @traits = WineTrait.where('parent_id !=0')
  end

  def color
    @categories = WineColor.where(:parent_id => 0)
    @traits = WineColor.where('parent_id !=0')
    render 'trait'
  end

  private

  def new_normal_comment(commentable)
    @commentable = commentable
    @comment = commentable.comments.build
  end

end