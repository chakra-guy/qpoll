# Questions

- Can I update poll options from both endpoints? -> `/polls/:id/` and `/polls/:id/poll-options/:option-id/`
- What's best practise for `poll_options` in Views
  -- :preload in list view or have 2 different views?
- CRUD resource from 2 endpoints? (dedicated and nested)
- Is it best practise to use binary_id over id for ecto types?
- PollController: what's best practise for key name changes options -> poll_options?
- What's a common way to write this: `polls.ex -> by_poll_id/2` (list_poll_options or list_poll_options_by_poll)
- on a GET-PUT-DELETE `/polls/:id/options` requests, should I check whether the poll_option_ids belong to the poll_id? (same for voting -> check both poll and option?)
- `POST /polls/:id/options`
  - assoc_constraint?
  - create_poll_option()?
- `vote_view.ex -> index.json + counted_vote.json`
- `changeset_with_options` needs end-to-end review
  - also do i need to have a separate changeset for this?
    -> separate changeset for `|> cast_assoc(:poll_options)`?
- Ecto.assoc_loaded?(votes) in poll_option_view.ex?
- version the api?
- delete publish or post unpublish?
- json api camelcase or snake case for properties?
- add clase for ecto assoc not loaded? `get_poll_option`
- `update_poll_option()` what to do will poll?

# Resources

- https://lobotuerto.com/blog/building-a-json-api-in-elixir-with-phoenix/
- https://ezcook.de/2018/05/15/cast-assoc/
