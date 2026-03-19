FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY CSharp-hello.csproj .
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

COPY --from=build /app .

ENV HOST=0.0.0.0
ENV PORT=8080
ENV LOG_LEVEL=Information
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 8080

STOPSIGNAL SIGTERM

ENTRYPOINT ["dotnet", "CSharp-hello.dll"]
