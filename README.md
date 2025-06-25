# Loop SDK

A TypeScript SDK for the Loop API, automatically generated from OpenAPI specifications. This SDK provides a type-safe and easy-to-use interface for interacting with the Loop backend services.

## 📦 Installation

```bash
npm install @nickloopdsp/loop-sdk
```

## 🚀 Quick Start

```typescript
import { LoopApi } from '@nickloopdsp/loop-sdk';

// Initialize the API client
const api = new LoopApi({
  baseURL: 'http://localhost:3001/api',
  // Add your authentication headers here
  headers: {
    'Authorization': 'Bearer your-token-here'
  }
});

// Use the API
try {
  // Example API call (adjust based on your actual endpoints)
  const response = await api.someEndpoint();
  console.log(response.data);
} catch (error) {
  console.error('API Error:', error);
}
```

## 🔧 Configuration

The SDK is built using TypeScript and Axios, providing:

- **Type Safety**: Full TypeScript support with generated types
- **Axios-based**: Reliable HTTP client with request/response interceptors
- **OpenAPI Generated**: Automatically generated from your API specification
- **ES6 Support**: Modern JavaScript features enabled

## 🛠️ Development

### Prerequisites

- Node.js (v14 or higher)
- NestJS development server running on `http://localhost:3001`

### Building the SDK

1. **Start the NestJS development server**:
   ```bash
   # In your NestJS project directory
   npm run start:dev
   ```

2. **Generate the SDK**:
   ```bash
   # Build and link locally
   ./make_publish_sdk.sh -l
   
   # Or build and publish
   ./make_publish_sdk.sh -p
   ```

### Available Build Options

- `-l`: Build and create npm link for local development
- `-p`: Build and publish to npm registry
- `-a`: Auto-increment version number
- `-v <version>`: Set specific version number
- `-t`: Create Git tag after publishing

### Local Development

For local development, the script will automatically:
1. Generate the SDK from your running API
2. Create an npm link
3. Apply the link to the `loop-frontend` repository (if found)

## 📋 Features

- **Automatic Generation**: SDK is automatically generated from your OpenAPI specification
- **Type Safety**: Full TypeScript support with generated interfaces
- **Error Handling**: Built-in error handling and type-safe responses
- **Authentication**: Support for various authentication methods
- **Modern JavaScript**: ES6+ features and modern syntax

## 🔗 Related Projects

- **Frontend**: [loop-frontend](https://github.com/nickloopdsp/loop-frontend) - Frontend application using this SDK
- **Backend**: NestJS API server providing the OpenAPI specification

## 📝 API Documentation

The SDK is generated from the OpenAPI specification served by your NestJS application. To view the full API documentation:

1. Start your NestJS development server
2. Visit `http://localhost:3001/api/docs` for the Swagger UI
3. Or access the OpenAPI JSON at `http://localhost:3001/api/docs-json`

## 🤝 Contributing

1. Make changes to your NestJS API
2. Update the OpenAPI specification
3. Regenerate the SDK using the build script
4. Test the changes in your frontend application

## 📄 License

ISC License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues

If you encounter any issues, please report them on the [GitHub Issues page](https://github.com/nickloopdsp/loop-sdk/issues).

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Version**: 0.0.3  
**Author**: Mohsan Khan  
**Repository**: [GitHub](https://github.com/nickloopdsp/loop-sdk)
