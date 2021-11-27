<template>
    <div class="row">
        <!-- project expenses  -->
            <div class="col-md-1">
            </div>
                <div class="col-md-10">
                    <h3 class="title text-left">Project Expenses</h3>
                    <table class="table">
                        <thead>
                            <tr class="row">
                                <th class="col-sm" v-for="header in headers">{{header.title}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="row" v-if="state.loading === true || state.data.length === 0">
                                <td>No expense data</td>
                            </tr>
                            <tr class="row" v-for="item in state.data">
                                <td class="col-sm">{{item.index}}</td>
                                <td class="col-sm">{{item.description}}</td>
                                <td class="col-sm">{{item.allocation}}</td>
                                <td class="col-sm">{{item.approvedAmount}}</td>
                                <td class="col-sm">{{item.state}}</td>
                                <td class="col-sm"><button class="btn btn-primary" @click="approveExpense(item.index)">Approve</button></td>
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
    import { Expense, getProjectExpenses, addListener } from "../api/contract";

    const headers = [
        {
            title: 'ID',
            dataIndex: 'index',
            key: 'index',
        },
        {
            title: 'Description',
            dataIndex: 'description',
            key: 'description'
        },
        {
            title: 'Allocation Asked',
            dataIndex: 'allocation',
            key: 'allocation'
        },
        {
            title: 'Approved Amount',
            dataIndex: 'approvedAmount',
            key: 'approvedAmount'
        },
        {
            title: 'State',
            dataIndex: 'state',
            key: 'state'
        },
        {
            title: "Approve",
            dataIndex: 'approve',
            key: 'approve'
        }
    ]

export default {
    name: "Expense",

    setup() {

        const route = useRoute();
        const projectId = parseInt(route.params.id as string);

        const state = reactive<{loading: boolean, data: Expense[]}>({
            loading: true,
            data: []
        })

        async function fetchData() {
            state.loading = true;
            try {
                state.data = await getProjectExpenses(projectId);
                state.loading = false;
            } catch (e) {
                console.log(e);
            }
        }

        addListener(fetchData)
        fetchData();

        const approveExpense = ((index: number) => {
            alert("TODO: will approve expense");
        })

        return {headers, projectId, state, approveExpense}
    }
}
</script>

