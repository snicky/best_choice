Dummy::Application.routes.draw do
  
  root to: 'main#landing'
  get 'sign_up' => 'main#sign_up'
  
end
