<template>
    <div>
        <div class="row">
            <div class="col-md-1">
            </div>
            <div class="col-md-10">
                <h2 class="title text-left">{{pageTitle()}}</h2>
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
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="row" v-if="state.loading === true || state.data.length === 0">
                            <td>No project data</td>
                        </tr>
                        <tr class="row" v-else v-for="item in state.data" :key="item.index">
                            <td class="col-sm" v-show="showMyProject(item)">{{item.title}}</td>
                            <td class="col-sm" v-show="showMyProject(item)">{{item.description}}</td>
                            <td class="col-sm" v-show="showMyProject(item)">{{new Date(parseInt(item.endTime) * 1000).toLocaleString()}}</td>
                            <!-- <td class="col-sm">{{item.endTime/1000}}</td> -->
                            <td class="col-sm" v-show="showMyProject(item)">{{item.amountFunded}}</td>
                            <td class="col-sm" v-show="showMyProject(item)">{{item.expenseCount}}</td>
                            <td class="col-sm" v-show="showMyProject(item)"><a class="nav-link" @click="openProjectDetail(item.index)">detail</a></td>
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
    import {
        useRoute,
        useRouter
    } from "vue-router";
    import {
        ref,
        reactive,
        watch
    } from "vue";
    import {
        addListener,
        Project,
        getProjects,
        getAccount
    } from "../api/contract";
    
    const headers = [{
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
            key: 'endTime'
        },
        {
            title: 'Current Donations (ETH)',
            dataIndex: 'amountFunded',
            key: 'amountFunded'
        },
        {
            title: 'Expense Count (ETH)',
            dataIndex: 'expenseCount',
            key: 'expenseCount',
        },
        {
            title: "Detail",
            dataIndex: 'detail',
            key: 'detail'
        }
    ]
    
    export default {
        name: "Projects",
        setup() {
            const router = useRouter();
            const route = useRoute();
            // const pageTitle = ref('All Projects')
            // const pageUpdate = () => {
            //     console.log("updating mine", route.query.mine);
            //     mine.value = route.query.mine === 'true';
            //     if (mine.value === true) {
            //         pageTitle.value = 'My Projects';
            //     }
            // }
            // pageUpdate();
    
            const createProject = (() => {
                router.push({
                    name: "NewProject"
                })
            });
            const openProjectDetail = ((index: number) => {
                router.push({
                    name: "Project",
                    params: {
                        id: index
                    }
                })
            });
    
            const state = reactive < {
                loading: boolean,
                data: Project[],
                account: string
            } > ({
                loading: true,
                data: [],
                account: '',
            });
    
            async function fetchData() {
                state.loading = true;
                try {
                    state.account = await getAccount();
                    state.data = await getProjects();
                    state.loading = false;    
                } catch (e) {
                    console.log(e);
                }
            }
            addListener(fetchData);
            fetchData();

            const showMyProject = (project: Project) => {
                const route = useRoute();
                if (route.query.mine === 'true') {
                    return project.founder === state.account;
                }
                return true;
            }

            const pageTitle = () => {
                const route = useRoute();
                if (route.query.mine === 'true') {
                    return "My Projects"
                }
                return "All Projects"
            }

            return {
                createProject,
                openProjectDetail,
                state,
                headers,
                pageTitle,
                showMyProject
            };
        }
    }
</script>

<style>
    
</style>