# Use the latest version of Alpine Linux as the base image
FROM alpine:latest

# ask name for user input
ARG NAME=jb

# transfer the user input to environment variable
ENV NAME=${NAME}

# print Hello + the user input
CMD ["sh", "-c", "echo Hello, ${NAME}!"]