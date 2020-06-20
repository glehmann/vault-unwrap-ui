module.exports = {
  "transpileDependencies": [
    "vuetify"
  ],
  devServer: {
    proxy: {
      "^/v1/": {
        target: "http://localhost:8200",
        pathRewrite: { "^/v1/": "/v1/" },
        changeOrigin: true,
        logLevel: "debug"
      }
    }
  }
}
