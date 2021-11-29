<template>
    <div>
        <div class="row">
            <div class="col-md-1">
			    </div>
            <div class="col-md-10">
                <h2 class="title text-left">New Project</h2>
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
                        <label for="founderAddress" class="col-sm col-form-label">Founder</label>
                        <div class="col-sm">
                            <input type="text" readonly class="form-control-plaintext" v-model="founderAddress">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_title" class="col-sm col-form-label">Project Title</label>
                        <div class="col-sm">
                            <input type="text" class="form-control" v-model="projectTitle" placeholder="your project title...">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_description" class="col-sm col-form-label">Project Description</label>
                        <div class="col-sm">
                            <textarea class="form-control rounded-0" v-model="projectDescription" rows="3" placeholder="your project description..."></textarea>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_endtime" class="col-sm col-form-label">Project End Time</label>
                        <div id="project-date-picker" class="col-sm">
                            <Datepicker v-model="endTime"/>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_submit" class="col-sm col-form-label"></label>
                        <div class="col-sm">
                            <button type="submit" class="btn btn-primary float-left" :disabled="!(projectTitle && projectDescription && founderAddress && endTime)">
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
</template>

<script>
    import { ref } from 'vue';
    import {useRouter} from 'vue-router';
    import Datepicker from 'vue3-date-time-picker';
    import 'vue3-date-time-picker/dist/main.css';
    import {getAccount, addListener, createProject} from "../api/contract";

    export default {
        components: {
            Datepicker
        },
        setup() {
            const router = useRouter()
            const endTime = ref('');
            const founderAddress = ref('0x0000000000000000000000000000000000000000');
            const projectTitle = ref('');
            const projectDescription = ref('');

            async function getAccountName() {
                founderAddress.value = await getAccount();
            }

            getAccountName();
            addListener(getAccountName)

            const onSubmit = (async() => {
                const seconds = Math.ceil(new Date(endTime.value) / 1000);
                try {
                    await createProject(projectTitle.value, projectDescription.value, seconds, founderAddress.value);
                    // router.push({path: '/projects', query: {mine: true}});
                    router.push({name: "MyProjects"});
                } catch (e) {
                    console.log(e)
                }
            });

            return {
                endTime, founderAddress, projectTitle, projectDescription, onSubmit
            };
        },
    }
</script>

<style>
    
</style>