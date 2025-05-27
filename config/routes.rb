Rails.application.routes.draw do
  root 'entries#landing_page'
  get 'thanks', to: 'entries#thanks', as: :thanks
  resources :entries, only: [:create]
end
