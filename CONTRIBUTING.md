# Contributing to CryptoScreen

Thank you for helping make CryptoScreen better! Please follow these guidelines for all pull requests:

## PR Etiquette
- Fork and branch from `main`.
- Write clear, descriptive commit messages.
- Open a pull request with a summary of changes and screenshots if UI-related.
- Ensure all CI checks (tests, RuboCop) pass before requesting review.
- At least one peer approval is required before merge.

## Code Style & Quality
- Follow RuboCop + rubocop-rails; run `bin/rubocop` before pushing.
- Keep files ≤200 LOC and single responsibility; extract services/components as needed.
- Use early returns, keyword arguments, and immutable data.
- Place business logic in POROs under `app/domains`.
- UI fragments should use ViewComponent classes.

## Testing
- Use RSpec 5, FactoryBot, Capybara, and view_component-test.
- Cover all critical paths; aim for 100% coverage on new features.
- Run `bin/rake test` before submitting.

## API & Docs
- Document new endpoints with OpenAPI (RSwag).
- Update the README and style guide as needed.

## Security & Performance
- Validate all params (strong params or dry-validation).
- Never commit secrets; use encrypted credentials.
- Profile and cache where appropriate.

Thank you for contributing!
