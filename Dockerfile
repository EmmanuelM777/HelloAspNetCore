# Generated with View -> Command Pallette >Docker: Add Docker File to Worspace...
# Also created is .dockerignore to exclude certain files or directories from the image

# build the image with the following command line:
# PS C:\Users\emman\source\repos\HelloAspNetCore> docker build -t hello-aspnetcore:v1 .
# the -t swith if for specifying the tag name of the image including version (Image name must be all lowercase).
# The . at the end tells docker that the context of the build is the current directory when Dockerfile resides

# Run the image using the following commandline:
# docker run -it --rm -p 8080:80 hello-aspnetcore:v1
# The -it switch is to specify the interactive mode
# The --rm swith is to specify that the image should be removed after the application has finisghed running
# The -p swith is to specific the port mapping so the the app is accessible via port 8080

# Optimaized Base image definition (smaller image with only the files required to run the app)
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
# Set Working directory
WORKDIR /app
# Ports to expose the image
EXPOSE 80
EXPOSE 443

# SDK Base image definition (Larger image for building including SDK files)
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
# Set Working directory
WORKDIR /src
# Copy project file to current directory (being the working directoy)
COPY ["HelloAspNetCore.csproj", "./"]
# Restore the NuGet packages
RUN dotnet restore "HelloAspNetCore.csproj"
# Copy all the file into the same location
COPY . .
# Removed not required
# WORKDIR "/src/."
# Build project with the release configuration since the output is aimed at a deployment to docker
RUN dotnet build "HelloAspNetCore.csproj" -c Release -o /app/build

# Publish binaries
FROM build AS publish
RUN dotnet publish "HelloAspNetCore.csproj" -c Release -o /app/publish

# Copy files to final artifact /app/publish directory
FROM base AS final
WORKDIR /app
# --from="publish" is the name of the previous publish stage FROM build AS "publish"
COPY --from=publish /app/publish .
# Specify the entry point for the docker image, app type and dll name
ENTRYPOINT ["dotnet", "HelloAspNetCore.dll"]
