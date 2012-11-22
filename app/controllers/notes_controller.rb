# encoding: utf-8
class NotesController < ApplicationController
  def show
   result      = Notes::NotesRepository.find(params[:id])
   return render_404('') unless result['state']
   @note = Notes::NoteItem.new(result['data'])
   @user       = User.find(result['data']['uid'])
   notes_result = Notes::NotesRepository.find_by_user(result['data']['uid'], @note.note.id)
   @user_notes = Notes::HelperMethods.build_user_notes(notes_result)  if notes_result['state']
   wine_result =  Notes::NotesRepository.find_by_wine(@note.wine.vintage, @note.wine.sName, @note.wine.oName, @note.note.id)
   @wine_note_users = Notes::HelperMethods.build_wine_notes(wine_result)  if wine_result['state']
  end

end