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
                <form role="form">
                    <div class="form-group row">
                        <label for="founder_address" class="col-sm col-form-label">Founder Address</label>
                        <div class="col-sm">
                            <input type="text" readonly class="form-control-plaintext" id="founder_address" value="0x00000000000">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_title" class="col-sm col-form-label">Project Title</label>
                        <div class="col-sm">
                            <input type="text" class="form-control" id="project_title" placeholder="your project title...">
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_description" class="col-sm col-form-label">Project Description</label>
                        <div class="col-sm">
                            <textarea class="form-control rounded-0" id="project_description" rows="3" placeholder="your project description..."></textarea>
                        </div>
                    </div>
                    <!-- This will show for donator -->
                    <div class="form-group row">
                        <label for="project_endtime" class="col-sm col-form-label">Project End Time</label>
                        <div id="project-date-picker" class="col-sm">
                            <Datepicker v-model="date"/>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="project_submit" class="col-sm col-form-label"></label>
                        <div class="col-sm">
                            <button type="submit" class="btn btn-primary float-left">
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
    import { ref } from "vue";
    import Datepicker from "vue3-date-time-picker";
    import "vue3-date-time-picker/dist/main.css";

    export default {
        components: {
            Datepicker
        },
        setup() {
            const date = ref(new Date());

            return {
                date,
            };
        },
    }
</script>

<style>
    
</style>