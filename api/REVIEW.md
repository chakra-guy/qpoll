# Questions

- Can I update poll options from both endpoints?
  -- `/polls/:id/` and `/polls/:id/poll-options/:option-id/`
  -- CRUD resource from 2 endpoints? (dedicated and nested)

- What's best practise for `poll_options` in Views
  -- :preload in list view or have 2 different views?

- Is it best practise to use binary_id over id for ecto types?

- PollController: what's best practise for mappings?
  -- changes prop name from options to poll_options?

- Should I check whether the nested resource belongs to the parent resource?
  -- what's the best practise?
  -- example: on a GET-PUT-DELETE `/polls/:id/options` requests
  -- example: `update_poll_option()`

- What's the best practise for what I'm trying to do here:
  -- `vote_view.ex -> index.json + counted_vote.json`
  -- should this already be done in the controller or with SQL?

- Separate changeset for `cast_assoc(:poll_options)`?

- Ecto.assoc_loaded?(votes) in poll_option_view.ex?
  -- best practise for handling not-loaded-associations?

- version the api?

- json api camelcase or snake case for properties?

- DELETE /publish or POST /unpublish?

- Do you see that a genserver or cache could be used?

- Should I care about doc-tests?

# Resources

- https://lobotuerto.com/blog/building-a-json-api-in-elixir-with-phoenix/
- https://ezcook.de/2018/05/15/cast-assoc/
- (link to elixir forum where they discuss json api resources)
