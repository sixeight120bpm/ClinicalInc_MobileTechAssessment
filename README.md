# ClinicalInc_MobileTechAssessment
 Mobile Technical Assessment for Clinical Inc

Todo/post project thoughts:
- this is NOT a single responsibility class and it should be.
- Ideally, there would be seperate controllers for managing the map view, geocoding, location manager, and the search bar +search completer.
  - Currently there is still more dependence between areas that I would like.
  - Labels don't need to know about geocoding, geocoding doesn't need to know about the view. I'm relying on delegate actions to trigger changes instead of setting up my own events.
- No tests. It's a very thin layer, I'm not doing anything with the data, no transformation, there's not really anything to test in terms of the model.
  - API testing doesn't really falling in unit testing, since it relies on outside services.
    - Maybe that's still worth testing for documentation and to confirm I'm pulling the data I think I'm pulling?
  - UITesting would be worthwhile and I could have benefitted from learning more about that.
- No optonal requirements. I ran into time constraints and chose not to pursue those, but they would be worthwhile as a learning exercise.
- I left the API key visible in almost all of the commit history. I'm not sure how to hide it. This is something I hadn't considered, but now realize is very important when working with API keys. I will need to seek guidance on the best way to handle that.
