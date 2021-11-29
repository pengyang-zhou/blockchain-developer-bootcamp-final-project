<template>
<div>
    <div class="row">
        <!-- project expenses  -->
            <div class="col-md-1">
            </div>
                <div class="col-md-10">
                    <div class="row">
                        <h3 class="title text-left">Project Expenses</h3>
                    </div>
                    <div class="row">
                        <div class="col-md-10">
                        </div>
                        <div class="col-md-2">
                            <button v-if="founder===state.account" class="btn btn-primary mt-2" @click="createExpense">Create an Expense</button>
                        </div>
                     </div>
                    <div class="text-center">
                    <table class="table">
                        <thead>
                            <tr class="row">
                                <th class="col-sm">{{headers[0].title}}</th>
                                <th class="col-sm">{{headers[1].title}}</th>
                                <th class="col-sm">{{headers[2].title}}</th>
                                <th class="col-sm">{{headers[3].title}}</th>
                                <th class="col-sm">{{headers[4].title}}</th>
                                <th class="col-sm" v-show="founder!==state.account">{{headers[5].title}}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="text-center" v-if="state.loading === true || state.data.length === 0">
                                <td>No expense data</td>
                            </tr>
                            <tr class="row" v-for="item in state.data">
                                <td class="col-sm">{{item.index}}</td>
                                <td class="col-sm">{{item.description}}</td>
                                <td class="col-sm">{{item.allocation}}</td>
                                <td class="col-sm">{{item.approvedAmount}}</td>
                                <td class="col-sm" v-if="item.state=== '1'">Approved</td>
                                <td class="col-sm" v-else>Pending</td>
                                <!-- <td class="col-sm">{{item.state}}</td> -->
                                <td v-show="founder!==state.account" class="col-sm"><button class="btn btn-primary" @click="approveProjectExpense(item.index)" :disabled="item.state === '1'">Approve</button></td>
                            </tr>
                        
                        </tbody>
                    </table>
                    </div>
                </div>
                <div class="col-md-1">
                </div>
        </div>
        <message-info :message="state.message"></message-info>
    </div>
</template>

<script lang="ts">
    import { useRoute, useRouter } from 'vue-router'
    import { ref, reactive, toRefs, defineComponent } from "vue";
    import { Expense, getAccount, getProjectExpenses, addListener, approveExpense } from "../api/contract";
    import { Message } from '../models/Message';

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

export default defineComponent({
    name: "Expenses",
    props: {
        founder: {
            type: String,
            required: true
        }
    },
    setup(props, context) {
        const route = useRoute();
        const router = useRouter();
        const projectId = parseInt(route.params.id as string);
        const state = reactive<{
            loading: boolean,
            data: Expense[],
            account: string,
            message: Message
            }>({
            loading: true,
            data: [],
            account: '',
            message: {message: '', type: 0},
        })

        async function fetchData() {
            state.loading = true;
            try {
                state.account = await getAccount();
                state.data = await getProjectExpenses(projectId);
                state.loading = false;
            } catch (e) {
                console.log(e);
            }
        }

        addListener(fetchData)
        fetchData();

        const approveProjectExpense = (async(expenseId: number) => {
            console.log("approving expense " + expenseId);
            try {
                let res = await approveExpense(projectId, expenseId);
                console.log("res", res);
                state.message = {
                    message: 'Successully approved expense ' + expenseId,
                    type: 0,
                }
            } catch (e) {
                console.log(e)
                state.message = {
                    message: 'Failed to approve expense ' + expenseId + '. You may not have available donations to approve an expense.',
                    type: 1,
                }
            }

        }); 

        const createExpense = () => {
            router.push({name: "NewExpense", params: {id: projectId}})
        }

        return {headers, projectId, state, approveProjectExpense, createExpense}
    }
});
</script>
