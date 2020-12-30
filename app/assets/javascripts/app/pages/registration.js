App.addChild("Registration", {
  el: '#wmseed_bootstrap[data-controller-name="registrations"]',

  events: {
    'change input#user_show_password': 'showPassword'
  },

  showPassword: function(event) {
    return Skull.ShowPasswordInput.togglePass('input#user_password', this.$(event.target).prop('checked'));
  }
});
