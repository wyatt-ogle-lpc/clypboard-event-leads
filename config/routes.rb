Rails.application.routes.draw do
  root 'entries#landing_page'
  get 'thanks', to: 'entries#thanks', as: :thanks
  get 'game', to: 'entries#game', as: :game
  resources :entries, only: [:create]
  get  'entries/:expo', to: 'entries#landing_page', as: :expo_entries
  post 'entries/:expo', to: 'entries#create'
  get 'entries/:expo/thanks', to: 'entries#thanks', as: :expo_thanks
  get 'entries/:expo/game', to: 'entries#game', as: :expo_game
  get 'entries/:expo/raffle', to: 'raffle#raffle', as: :expo_raffle


end
