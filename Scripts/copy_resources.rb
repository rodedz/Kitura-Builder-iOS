# Copyright IBM Corporation 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gem 'xcodeproj'
require 'xcodeproj'

def add_copy_file_build_phase(project, target,  symbol_dst_subfolder_spec, resources_dirs)
    copy_build_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
    copy_build_phase.symbol_dst_subfolder_spec = symbol_dst_subfolder_spec
    target.build_phases << copy_build_phase

    resources_dirs.each { |dir|
        file_reference = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(project.main_group , dir ,:group)
        file_reference.last_known_file_type = 'folder'
        build_file = copy_build_phase.add_file_reference(file_reference)
        build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
    }
end

client_project_file = ARGV[0]
client_target = "ClientSide"
resources_dirs = ['ClientSide/Views','ClientSide/public','ClientSide/.build']
client_project = Xcodeproj::Project.open(client_project_file)
client_main_group = client_project.main_group

target_to_fix = (client_project.targets.select { |target| target.name == client_target }).first;

add_copy_file_build_phase(client_project, target_to_fix,  :resources, ['public', '.build'])
add_copy_file_build_phase(client_project, target_to_fix,  :executables, ['Views'])

client_project.save
