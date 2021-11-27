<template>
    <div class="row">
        <div class="col-md-1">
        </div>
        <div class="col-md-10">
            <h3 class="title text-left">Project Donations</h3>
            <table class="table">
                <thead>
                    <tr class="row">
                        <th class="col-sm" v-for="header in headers">{{header.title}}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="row" v-if="state.loading === true || state.data.length === 0">
                        <td>No donation data</td>
                    </tr>
                    <tr class="row" v-for="item in state.data">
                        <td class="col-sm">{{item.donator}}</td>
                        <td class="col-sm">{{item.total}}</td>
                        <td class="col-sm">{{item.available}}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="col-md-1">
        </div>
    </div>
</template>


<script lang="ts">
    import { useRoute } from 'vue-router'
    import { ref, reactive } from "vue";
    import { Donation, getProjectDonations, addListener } from "../api/contract";

    const headers = [
        {
            title: 'Donator',
            dataIndex: 'donator',
            key: 'donator',
        },
        {
            title: 'Total',
            dataIndex: 'total',
            key: 'total'
        },
        {
            title: 'Available',
            dataIndex: 'available',
            key: 'available'
        }
    ]

export default {
    name: "Donations",

    setup() {

        const route = useRoute();
        const projectId = parseInt(route.params.id as string);

        const state = reactive<{loading: boolean, data: Donation[]}>({
            loading: true,
            data: []
        })

        async function fetchData() {
            state.loading = true;
            try {
                state.data = await getProjectDonations(projectId);
                state.loading = false;
            } catch (e) {
                console.log(e);
            }
        }

        addListener(fetchData)
        fetchData();

        return {headers, projectId, state}
    }
}
</script>
