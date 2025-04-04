# Table Processor API

A Ruby on Rails API for converting HTML tables into a format suitable for parsing by language models.

## Live Demo

The Table Processor API is now available at [www.ichi.rest](https://www.ichi.rest). You can visit the website to learn more about the service and access the API documentation.

## Overview

This API takes HTML table content and processes it to extract structured data in a key-value format that can be easily understood by language models. It handles complex table structures including merged cells, headers, and special formatting.

## Features

- Process HTML tables into a key-value format
- Handle complex table structures with merged cells
- Support for headers in various formats
- Preserve original content while normalizing for processing
- Robust error handling

## API Documentation

The API documentation is available via Swagger UI at `/api-docs` when the application is running. The OpenAPI specification is also available in JSON format at `/swagger/v1/swagger.json`.

### Using the Swagger Documentation

1. Start the Rails server:
   ```
   rails server
   ```

2. Open your browser and navigate to:
   ```
   http://localhost:3000/api-docs
   ```

3. The Swagger UI provides an interactive interface where you can:
   - View detailed API specifications
   - Test the API endpoints directly from the browser
   - See request/response examples
   - View available parameters and response schemas

### API Endpoints

#### Process Table

```
POST /api/v1/tables/process
```

**Request Body:**

```json
{
  "html": "<table><tr><th>Header</th></tr><tr><td>Value</td></tr></table>"
}
```

**Response:**

```json
{
  "status": "success",
  "data": "Header: Value"
}
```

### Error Responses

The API returns appropriate HTTP status codes and error messages:

- `422 Unprocessable Entity`: When the request is missing required parameters or contains invalid data
- `500 Internal Server Error`: When an unexpected error occurs during processing

## Getting Started

### Prerequisites

- Ruby 3.0.0 or higher
- Rails 8.0.0 or higher
- PostgreSQL

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   bundle install
   ```
3. Set up the database:
   ```
   rails db:create db:migrate
   ```
4. Start the server:
   ```
   rails server
   ```

### Testing

Run the test suite:

```
bundle exec rails test
```

## Implementation Details

The table processing pipeline consists of several components:

1. **Parser**: Extracts headers and rows from HTML tables
2. **GridBuilder**: Builds a grid representation of the table
3. **HeaderAnalyzer**: Analyzes headers and their relationships
4. **ValueMapper**: Maps values to their corresponding headers
5. **OutputFormatter**: Formats the output for LLM consumption

## Making API Requests

You can interact with the API using various tools:

### Using curl

```bash
curl -X POST http://localhost:3000/api/v1/tables/process \
  -H "Content-Type: application/json" \
  -d '{"html": "<table><tr><th>Header</th></tr><tr><td>Value</td></tr></table>"}'
```

### Using Postman

1. Create a new POST request to `http://localhost:3000/api/v1/tables/process`
2. Set the Content-Type header to `application/json`
3. In the request body, select "raw" and "JSON", then enter your HTML table content
4. Send the request

### Using the Swagger UI

1. Navigate to `/api-docs` in your browser
2. Click on the POST `/api/v1/tables/process` endpoint
3. Click "Try it out"
4. Enter your HTML table in the request body
5. Click "Execute" to send the request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

