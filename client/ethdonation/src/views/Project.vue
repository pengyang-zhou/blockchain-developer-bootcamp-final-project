<template>
    <div>
        <message-info :message="state.message"></message-info>
        <div class="row">
            <div class="col-md-1">
            </div>
            <div class="col-md-10">
                <h2 class="title text-left">Project Detail</h2>
            </div>
            <div class="col-md-1">
            </div>
        </div>
        <div class="text-center" v-if="state.loading === true || state.noData">
            <p>No project data</p>
        </div>
        <div class="row" v-else>
            <div class="col-md-1">
            </div>
            <div class="col-md-10">
                <h3 class="title text-left">Project Information</h3>
                <form role="form" @submit.prevent="onSubmit">
                    <div class="form-group row">
                        <label for="founder_address" class="col-sm col-form-label">Founder Address</label>
                        <div class="col-sm">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.founder" placeholder="0x0000000000000000000000000000000000000000">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_title" class="col-sm-6 col-form-label">Project Title</label>
                        <div class="col-sm-6">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.title" placeholder="project title ...">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_description" class="col-sm-6 col-form-label">Project Description</label>
                        <div class="col-sm-6">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.description" placeholder="project description ...">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_endtime" class="col-sm-6 col-form-label">Project End Time</label>
                        <div class="col-sm-6">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.endTime" placeholder="Project End Time">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="amount_donated" class="col-sm-6 col-form-label">Amount Donated</label>
                        <div class="col-sm-6">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.amountFunded" placeholder="Amount Donated">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="amount_allocated" class="col-sm-6 col-form-label">Amount Allocated</label>
                        <div class="col-sm-6">
                            <input type="text" readonly class="form-control-plaintext" v-model="state.data.amountAllocated" placeholder="Amount Allocated">
                        </div>
                    </div>
    
                    <div class="form-group row" v-show="!state.noData && state.account !== state.data.founder">
                        <!-- <div class="form-group row"> -->
                        <label for="donate_amount" class="col-sm-6 col-form-label font-weight-bold">I would like to donate</label>
                        <div class="col-sm-2">
                            <input type="text" class="form-control" v-model="state.myDonateAmount" @keypress="onlyForCurrency">
                        </div>
                        <label class="col-sm-4 col-form-label text-left">ETH</label>
                    </div>
    
                    <div class="form-group row" v-show="!state.noData && state.account !== state.data.founder">
                        <!-- <div class="form-group row"> -->
                        <div class="col-sm">
                        </div>
                        <div class="col-sm">
                            <button type="submit" class="btn btn-primary float-left">
                                            Donate Now
                                    </button>
                        </div>
                    </div>
                </form>
            </div>
            <div class="col-md-1">
            </div>
        </div>
    
    
        <expenses :founder="state.data.founder" v-show="state.loading === false && !state.noData"></expenses>
    
        <donations :projectId="projectId" v-show="state.loading === false && !state.noData"></donations>
    
    </div>
</template>

<script lang="ts">
    import {ref,reactive,inject,watch,defineComponent} from 'vue';
    import {useRoute} from 'vue-router';
    import {Project,addListener,getAccount,getProject,donate} from '../api/contract';
    import {Message} from '../models/Message';
    
    export default {
        setup() {
            const onRefresh = inject<Function>('reload')
            const route = useRoute();
            const projectId = parseInt(route.params.id as string);
    
            const state = reactive < {
                loading: boolean,
                data: Project,
                account: String,
                noData: boolean,
                myDonateAmount: string,
                message: Message,
            } > ({
                loading: true,
                data: {
                    index: 0,
                    founder: '',
                    title: '',
                    description: '',
                    endTime: '',
                    amountFunded: 0,
                    amountAllocated: 0,
                    expenseCount: 0
                },
                account: '',
                noData: true,
                myDonateAmount: '',
                message: {
                    message: '',
                    type: 0
                },
    
            })
    
            async function fetchData() {
                state.loading = true;
                try {
                    state.account = await getAccount();
                    state.data = await getProject(projectId);
                    state.loading = false;
                    if (state.data.founder === '0x0000000000000000000000000000000000000000') {
                        state.noData = true;
                    } else {
                        state.noData = false;
                    }

                    state.data.endTime = new Date(parseInt(state.data.endTime) * 1000).toLocaleString()
                } catch (e) {
                    console.log(e);
                }
            }
    
            const onSubmit = async() => {
                try {
                    await donate(projectId, state.myDonateAmount);
                    state.message = {
                        type: 0,
                        message: "successfully donated " + state.myDonateAmount + " ETH to project " + state.data.title,
                    }
                    onRefresh && onRefresh()
                } catch (e) {
                    state.message = {
                        type: 1,
                        message: "failed submit donation to project " + state.data.title + ". error: " + e.message,
                    }
                    console.log(e)
                }
            };
    
            addListener(fetchData)
            fetchData();

            watch(() => state.myDonateAmount, (newVal, prevVal) => {
                if (newVal.includes('.')) {
                    state.myDonateAmount = newVal.split('.')[0] + '.' + newVal.split('.')[1].slice(0, 2);
                }
            })
    
            return {
                projectId,
                state,
                onSubmit
            }
        }
    }
</script>

<style>
    
</style>