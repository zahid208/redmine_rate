resources :rates
match 'rate_caches',
      to: 'rate_caches#update',
      via: [:get, :put]
