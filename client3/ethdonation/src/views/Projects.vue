<template>
    <div>
        <div class="row">
            <div class="col-md-1">
			    </div>
            <div class="col-md-10">
                <h2 class="title text-left">All Projects</h2>
            </div>
            <div class="col-md-1">
			    </div>
        </div>
        <div class="row">
            
                <div class="col-md-9">
			    </div>
                <div class="col-md-2">
                    <button class="btn btn-primary float-right mt-2" @click="createProject">Create a Project</button>
                </div>
                <div class="col-md-1">
			    </div>
        </div>
        <div class="row">
            <div class="col-md-1">
			    </div>
            <div class="col-md-10">
                <table class="table">
                    <thead>
                        <tr class="row">
                            <th class="col-sm" v-for="header in headers">{{header.title}}</th>
                            <!-- <th class="col-sm">Project Title</th>
                            <th class="col-sm">Project Description</th>
                            <th class="col-sm">Project End Time</th>
                            <th class="col-sm">Current Donations</th>
                            <th class="col-sm">Expenses Count</th>
                            <th class="col-sm">Detail</th> -->
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="state.loading === true">
                            <td>No data</td>
                        </tr>
                        <tr v-else v-for="item in state.data">
                            <td class="col-sm">{{item.title}}</td>
                            <td class="col-sm">{{item.description}}</td>
                            <td class="col-sm">{{item.date}}</td>
                            <td class="col-sm">{{item.amountFunded}}</td>
                            <td class="col-sm">{{item.expenseCount}}</td>
                            <td class="col-sm"><a class="primary_link" @click="openProjectDetail(item.index)">detail</a></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-md-1">
			    </div>
        </div>
    </div>
</template>

<script lang="ts">
    import { useRouter } from "vue-router";
    import { ref, reactive } from "vue";
    import { addListener, Project, getProjects } from "../api/contract";

    const headers = [
        {
            title: 'Project Title',
            dataIndex: 'title',
            key: 'title',
        },
        {
            title: 'Project Description',
            dataIndex: 'description',
            key: 'description'
        },
        {
            title: 'Project End Time',
            dataIndex: 'endTime',
            key: 'endTime',
            slots: { customRender: 'time' }
        },
        {
            title: 'Current Donations(ETH)',
            dataIndex: 'amountFunded',
            key: 'amountFunded'
        },
        {
            title: 'Expense Count(ETH)',
            dataIndex: 'expenseCount',
            key: 'expenseCount',
        },
        {
            title: "Detail",
            dataIndex: 'detail',
            key: 'detail',
            slots: { customRender: 'detail' }
        }
    ]

    export default {
        name: "Projects",
        setup(){
            const router = useRouter()
            const createProject = (() => {
                router.push({name: "NewProject"})
            })
            const openProjectDetail = ((index : number) => {
                router.push({name: "Project", params: {id: index}})
            })

            const state = reactive<{loading: boolean, data: Project[]}>({
                loading: true,
                data: []
            })

            async function fetchData() {
                state.loading = true;
                try {
                    state.data = await getProjects();
                    state.loading = false;
                } catch (e) {
                    console.log(e);
                }
            }

            addListener(fetchData)
            fetchData();

            return {createProject, openProjectDetail, state, headers}
        }
    }
</script>

<style>
</style>