<template>
    <div class="container-fluid">
        <div class="row">
        <div class="col-md-12" v-show="message.message && message.type === 0">
            <label class="succeeded">{{message.message}}</label>
        </div>
        <div class="col-md-12" v-show="message.message && message.type === 1">
            <label class="failed">{{message.message}}</label>
        </div>
        </div>
    </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent ({
    name: "MessageInfo",
    props: {
        message: Object,
    },
    setup (props) {
        return { props };
    }
});
</script>

<style scoped>

.succeeded {
    color: green;
}
.failed {
    color: red;
}
</style>
