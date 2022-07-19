FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
EXPOSE 6000

ENV ASPNETCORE_URLS=http://+:6000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["*.sln", "."]
COPY ["Edft.DeepSea.Compass.Api/*.csproj", "./Edft.DeepSea.Compass.Api/"]
COPY ["Edft.DeepSea.Compass.Api.Tests/*.csproj", "./Edft.DeepSea.Compass.Api.Tests/"]
COPY ["Edft.DeepSea.Compass.Api.ComponentTests/*.csproj", "./Edft.DeepSea.Compass.Api.ComponentTests/"]
RUN dotnet restore
COPY . .
RUN dotnet build -c Release -o /app/build 
  
FROM build AS testrunner
WORKDIR /src/Edft.DeepSea.Compass.Api.Tests
CMD dotnet test --no-restore --nologo --logger:trx -r /app/publish/tests 

FROM build AS test
WORKDIR /src/Edft.DeepSea.Compass.Api.Tests
RUN ["dotnet", "test", "--logger:trx"]

FROM build AS componenttestrunner
WORKDIR /src/Edft.DeepSea.Compass.Api.ComponentTests
CMD dotnet test --no-restore --nologo --logger:trx -r /app/publish/componenttests 

FROM test AS publish
WORKDIR /src/Edft.DeepSea.Compass.Api
RUN dotnet publish "Edft.DeepSea.Compass.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Edft.DeepSea.Compass.Api.dll"]