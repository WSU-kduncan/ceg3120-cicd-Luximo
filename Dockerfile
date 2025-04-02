# Use official Node.js 18 image as base
FROM node:18-bullseye

# Set the working directory inside the container
WORKDIR /app

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Copy package.json and package-lock.json first (to leverage caching)
COPY angular-site/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY angular-site/ .

# Expose the port Angular uses
EXPOSE 4200

# Run the Angular development server
CMD ["ng", "serve", "--host", "0.0.0.0"]
