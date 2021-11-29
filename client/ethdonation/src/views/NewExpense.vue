<template>
    <div>
        <message-info :message="state.message"></message-info>
        <div>
            <div v-if="!state.noData">
        <div class="row">
            <div class="col-md-1">
			    </div>
            <div class="col-md-10">
                <h2 class="title text-left">New Expense</h2>
            </div>
            <div class="col-md-1">
			    </div>
        </div>

        <div class="row">
            <div class="col-md-1">
            </div>
            <div class="col-md-10">
                <form role="form" @submit.prevent="onSubmit">
                    <div class="form-group row align-items-left">
                        <label for="founderAddress" class="col-sm col-form-label">Project Title</label>
                        <div class="col-sm">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.project.title">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_title" class="col-sm col-form-label">Expense Description</label>
                        <div class="col-sm">
                            <input type="text" class="form-control" v-model="state.expenseDescription" placeholder="your expense title...">
                        </div>
                    </div>
                    <div class="form-group row align-items-left">
                        <label for="founderAddress" class="col-sm-6 col-form-label">Allocation Asked</label>
                        <div class="col-sm-3">
                            <input type="text" class="form-control" v-model="state.allocationAsked">
                        </div>
                        <label class="col-sm-3 col-form-label text-left">ETH</label>
                    </div>
                    <div class="form-group row">
                        <label for="project_submit" class="col-sm col-form-label"></label>
                        <div class="col-sm">
                            <button type="submit" class="btn btn-primary float-left" :disabled="!(projectId && state.expenseDescription && state.allocationAsked)">
                                Submit
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="col-md-1">
            </div>
        </div>
        </div>
    </div>
    </div>
</template>

<script lang="ts">
import {ref, reactive,watch} from 'vue';
import {useRoute, useRouter} from 'vue-router';
import {addListener, getProject, getAccount, createExpense, Project} from "../api/contract";
import {Message} from '../models/Message';

export default {
    setup() {
        const route = useRoute();
        const router = useRouter();
        const projectId = parseInt(route.params.id as string)

        const state = reactive < {
                account: String,
                project: Project,
                expenseDescription:String,
                allocationAsked:String,
                noData: boolean,
                message: Message,
            } > ({
                account: '',
                project: {
                    index: 0,
                    founder: '',
                    title: '',
                    description: '',
                    endTime: '',
                    amountFunded: 0,
                    amountAllocated: 0,
                    expenseCount: 0
                },
                expenseDescription: '',
                allocationAsked:'',
                noData: false,
                message: {
                    message: '',
                    type: 0
                },
            })
        
        const noDataMessage = () => {
            state.message = {
                message: "you don't have the right to view this page",
                type: 1
            }
        }

        async function fetchData() {
            try {
                state.project = await getProject(projectId);
                if (state.project.founder === '0x0000000000000000000000000000000000000000') {
                    state.noData = true;
                    noDataMessage();
                }
            } catch (e) {
                console.log(e);
            }
            
        }
        fetchData();

        async function getAccountName() {
            state.account = await getAccount();
            if (state.project.founder.toString() !== state.account.toString()) {
                state.noData = true;
                noDataMessage();
            }
        }
        getAccountName();
        addListener(getAccountName)

        const onSubmit = (async() => {
            try {
                await createExpense(projectId, state.expenseDescription.toString(), state.allocationAsked.toString());
                state.message = {
                    message: 'Successfully created an expense: ' + state.expenseDescription,
                    type: 0,
                }
                router.push({name: "Project", params: {id: projectId}});
            } catch (e) {
                state.message = {
                    message: 'Failed to create an expense. Error: ' + e.message,
                    type: 1,
                }
            }
        });

        watch(() => state.allocationAsked, (newVal, prevVal) => {
                if (newVal.includes('.')) {
                    state.allocationAsked = newVal.split('.')[0] + '.' + newVal.split('.')[1].slice(0, 2);
                }
            })

        return {projectId, onSubmit, state}
    }
}
</script>

