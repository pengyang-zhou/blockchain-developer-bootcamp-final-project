<template>
    <div>
        <div class="row">
            <div class="col-md-1">
			    </div>
            <div class="col-md-10">
                <h2 class="title text-left">Project Detail {{index}}</h2>
            </div>
            <div class="col-md-1">
			    </div>
        </div>
        <div class="row">
                <div class="col-md-1">
                </div>
                <div class="col-md-10">
                    <h3 class="title text-left">Project Information</h3>
                    <form role="form">
                        <div class="form-group row">
                                <label for="founder_address" class="col-sm col-form-label">Founder Address</label>
                            <div class="col-sm">
                                <input type="text" readonly class="form-control-plaintext" id="founder_address" placeholder="0x00000000000">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label for="project_title" class="col-sm-6 col-form-label">Project Title</label>
                            <div class="col-sm-6">
                                <input type="text" readonly class="form-control-plaintext" id="project_title" placeholder="Project Title">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label for="project_description" class="col-sm-6 col-form-label">Project Description</label>
                            <div class="col-sm-6">
                                <textarea type="text" readonly class="form-control rounded-0" id="project_description" rows="3" placeholder="project description" ></textarea>
                            </div>
                        </div>
                        <div class="form-group row">
                            <label for="project_endtime" class="col-sm-6 col-form-label">Project End Time</label>
                            <div class="col-sm-6">
                                <input type="text" readonly class="form-control-plaintext" id="project_endtime" placeholder="Project End Time">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label for="amount_donated" class="col-sm-6 col-form-label">Amount Donated</label>
                            <div class="col-sm-6">
                                <input type="text" readonly class="form-control-plaintext" id="amount_donated" placeholder="Amount Donated">
                            </div>
                        </div>
                        <div class="form-group row">
                            <label for="amount_allocated" class="col-sm-6 col-form-label">Amount Allocated</label>
                            <div class="col-sm-6">
                                <input type="text" readonly class="form-control-plaintext" id="amount_allocated" placeholder="Amount Allocated">
                            </div>
                        </div>

                        <div class="form-group row">
                            <label for="donate_amount" class="col-sm-6 col-form-label font-weight-bold">I would like to donate</label>
                            <div class="col-sm-1">
                                <input type="text" class="form-control" id="donate_amount" value="0">
                            </div>
                            <label class="col-sm-5 col-form-label text-left">ETH</label>
                        </div>
                        <div class="form-group row">
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

         <div class="row">
                <div class="col-md-1">
                </div>
                <div class="col-md-10">
                    <h3 class="title text-left">Project Donations</h3>
                    <table class="table">
                        <thead>
                            <tr class="row">
                                <th class="col-sm-3">Donator</th>
                                <th class="col-sm-3">Total Donated Amount</th>
                                <th class="col-sm-6">Amount Available for Expenses</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="row">
                                <td class="col-sm-3">0x1234</td>
                                <td class="col-sm-3">10</td>
                                <td class="col-sm-6">10</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col-md-1">
                </div>
        </div>
        <donations></donations>

        <div class="row">
        <!-- project expenses  -->
            <div class="col-md-1">
            </div>
                <div class="col-md-10">
                    <h3 class="title text-left">Project Expenses</h3>
                    <table class="table">
                        <thead>
                            <tr class="row">
                                <th class="col-sm">Description</th>
                                <th class="col-sm">Allocation Asked</th>
                                <th class="col-sm">Approved Amount</th>
                                <th class="col-sm">Approve</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="row">
                                <td class="col-sm">expense xx</td>
                                <td class="col-sm">10</td>
                                <td class="col-sm">10</td>
                                <td class="col-sm">
                                    <!-- This will only show if the account is a donator -->
                                    <button class="btn btn-primary float-center">Approve</button>
                                </td>
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
    import { computed } from 'vue'
    import { useRoute } from 'vue-router'
    import Donations from '../components/Donations'

    export default {

        setup () {
            const route = useRoute();

            const index = parseInt(route.params.id as string);
            return {
                index
            }
        }

        
    }
</script>

<style>
</style>