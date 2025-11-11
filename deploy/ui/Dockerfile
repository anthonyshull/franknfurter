FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY ui/package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY ui/ ./

# Expose Vite dev server port
EXPOSE 3001

# Start Vite dev server with hot reload
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
