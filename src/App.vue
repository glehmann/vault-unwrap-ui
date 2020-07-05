<template>
  <v-app id="inspire">
    <v-main>
      <v-container class="fill-height" fluid>
        <v-row align="center" justify="center">

          <v-alert type="error" v-if="error !== ''">
            {{error}}
          </v-alert>
          <v-col cols="12" sm="8" v-if="error === ''">
            <v-toolbar flat>
              <v-toolbar-title>Secret</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-tooltip bottom>
                <template v-slot:activator="{ on }">
                  <v-switch label="JSON" v-model="json" v-on="on"/>
                </template>
                <span>Source</span>
              </v-tooltip>
            </v-toolbar>
            <v-card outlined v-if="json">
              <pre>{{raw_data}}</pre>
            </v-card>
            <v-card-text v-if="!json">
              <v-text-field v-for="item in secrets" :key="item.key"
                append-icon="mdi-content-copy"
                :prepend-inner-icon="show[item.key] ? 'mdi-eye' : 'mdi-eye-off'"
                :type="show[item.key] ? 'text' : 'password'"
                :label="item.key"
                :value="item.value"
                class="input-group--focused"
                @click:prepend-inner='show[item.key] = !show[item.key]'
                @click:append='toClipboard(item.key)'
                readonly
                outlined
              />
            </v-card-text>
          </v-col>
          <v-alert type="info" v-if="error === ''" class="elevation-12">
            This secret is only accessible once. It won't be possible to open this
            link again in the future.
          </v-alert>

        </v-row>
      </v-container>
      <v-snackbar v-model="snackbar" timeout=1500>
        {{ message }}
      </v-snackbar>
    </v-main>
  </v-app>
</template>

<script>
  import axios from 'axios';
  export default {
    props: {
      source: String,
    },
  data () {
    return {
      secrets: [],
      show: {},
      error: '',
      json: false,
      raw_data: {},
      message: '',
      snackbar: false,
    }
  },
  methods: {
    toClipboard: function (key) {
      navigator.clipboard.writeText(this.raw_data[key])
        .then(() => {
          this.message = "Secret '" + key + "' copied to clipboard.";
          this.snackbar = true;
        })
        .catch(err => {
          // This can happen if the user denies clipboard permissions:
          console.error('Could not copy text: ', err);
        });
    }
  },
  mounted() {
      var token = window.location.pathname.split('/').reverse()[0];
      axios.post('/v1/sys/wrapping/unwrap', '',
        {
          headers: {
              'X-Vault-Token': token,
              'Content-Type': 'application/json',
          }
        })
        .then(response => {
          var data = response.data.data.data;
          var secrets = [];
          var show = {};
          for(var key in data) {
            secrets.push({'key': key, 'value': data[key]});
            show[key] = false;
          }
          this.raw_data = data;
          this.secrets = secrets;
          this.show = show;
        })
        .catch(error => {
          try {
            this.error = error.response.data.errors[0];
          } catch(err) {
            this.error = error;
          }
        });
  }
}
</script>
