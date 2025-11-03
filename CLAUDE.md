# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nacelle is a Rails engine that enables embedding dynamic cell components into CMS content. It works by parsing `<cell>` tags in HTML responses and replacing them with rendered cell content via a controller after filter.

## Core Architecture

### Cell Execution Flow

1. **Request Processing**: HTML responses flow through `Nacelle::AfterFilter` global controller after filter (registered in `lib/nacelle.rb:11`)
2. **Tag Parsing**: AfterFilter scans the response body for `<cell>` tags using regex and XML parsing (`lib/nacelle/after_filter.rb:38-46`)
3. **Cell Instantiation**: Tags like `<cell name="my_account/form" />` are converted to `MyAccountCell#form` calls
4. **Rendering**: Cells render their views from `app/cells/` directory structure

### Key Components

- **Nacelle::Cell** (`lib/nacelle/cell.rb`): Base class for all cells
  - Provides controller context (request, session, cookies) to cells
  - Implements custom rendering that looks up views in `app/cells/` directory
  - Supports helper modules and helper methods
  - Has cache key/timestamp methods for fragment caching

- **Nacelle::AfterFilter** (`lib/nacelle/after_filter.rb`): Middleware that processes HTML responses
  - Only processes `text/html` content types
  - Parses `<cell name="cell_name/action" attr="value" />` tags
  - Instantiates cell classes and invokes actions with attributes

- **Nacelle::HasCells** (`lib/nacelle/has_cells.rb`): ActiveRecord mixin
  - Use `has_cells :column_name` to scan model columns for embedded cells
  - Returns array of cell classes found in the content

- **Nacelle::CellsSerializer** (`lib/nacelle/cells_serializer.rb`): JSON API for CKEditor integration
  - Endpoint at `/nacelle/cells.json` lists all available cells and their actions
  - Discovers cells by requiring all files in `app/cells/*.rb`
  - Optionally loads form HTML from `app/cells/{cell}/{action}_form.html.erb`

### Cell Conventions

- Cell classes must inherit from `Nacelle::Cell` to appear in CKEditor
- Cell class names follow pattern: `{Name}Cell` (e.g., `TestCell`, `MyAccountCell`)
- Cell views live in `app/cells/{cell_name}/{action}.html.erb`
- Actions can accept zero arguments or a hash of attributes
- Action methods are alphabetically ordered in the CKEditor menu

## Development Commands

### Running Tests
```bash
bundle exec rake          # Run all specs (default task)
bundle exec rspec         # Run all specs
bundle exec rspec spec/acceptance/nacelle_spec.rb  # Run specific spec file
```

### Testing Across Rails Versions
```bash
bundle exec appraisal install          # Install dependencies for all Rails versions
bundle exec appraisal rails-7.1 rspec  # Run specs against specific Rails version
```

## Testing Setup

The test suite uses RSpec with Capybara for acceptance testing. The spec creates a minimal Rails test app inline (`spec/acceptance/nacelle_spec.rb:5-16`) to test the engine's middleware behavior in a realistic environment.

When writing new tests:
- Place acceptance tests in `spec/acceptance/`
- The test app is configured with `secret_key_base`, `eager_load: false`, and `hosts: nil`
- Test cells should inherit from `Nacelle::Cell` and set `view_path` appropriately

## File Structure

```
lib/nacelle/
  ├── cell.rb              # Base cell class with rendering logic
  ├── after_filter.rb      # Middleware for processing <cell> tags
  ├── has_cells.rb         # ActiveRecord mixin for scanning content
  └── cells_serializer.rb  # JSON API for CKEditor integration

app/
  ├── controllers/nacelle/
  │   └── cells_controller.rb  # Serves JSON list of cells
  └── assets/javascripts/
      ├── nacelle/ckeditor.js       # CKEditor integration entry point
      └── ckeditor/plugins/cells/   # CKEditor plugin for inserting cells
```

## Important Implementation Details

- Cell tag parsing uses `Hash.from_xml` (requires Nokogiri backend)
- The AfterFilter runs on all ActionController::Base after_actions
- Cell names in tags use underscore format: `<cell name="my_account/form" />`
- Cell classes use CamelCase: `MyAccountCell`
- Action arity is checked to determine whether to pass attributes hash
- Missing cells/actions render error message: `<strong>Cell "{name} {action}" not found!</strong>`
