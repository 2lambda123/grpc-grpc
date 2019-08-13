# Copyright 2019 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This is for the gRPC build system. This isn't intended to be used outsite of
# the BUILD file for gRPC. It contains the mapping for the template system we
# use to generate other platform's build system files.
#
# Please consider that there should be a high bar for additions and changes to
# this file.
# Each rule listed must be re-written for Google's internal build system, and
# each change must be ported from one to the other.
#

load(
    "//bazel:generate_objc.bzl",
    "generate_objc",
    "generate_objc_hdrs",
    "generate_objc_srcs",
    "generate_objc_non_arc_srcs"
)
load("//bazel:protobuf.bzl", "well_known_proto_libs")

def grpc_objc_testing_library(
        name,
        srcs = [],
        hdrs = [],
        textual_hdrs = [],
        data = [],
        deps = [],
        defines = [],
        includes = []):
    """objc_library for testing, only works in //src/objective-c/tests

    Args:
        name: name of target
        hdrs: public headers
        srcs: all source files (.m)
        textual_hdrs: private headers
        data: any other bundle resources
        defines: preprocessors
        includes: added to search path, always [the path to objc directory]
        deps: dependencies
    """
    
    additional_deps = [
        ":RemoteTest",
        "//src/objective-c:grpc_objc_client_internal_testing",
    ]

    if not name == "TestConfigs":
        additional_deps += [":TestConfigs"]
    
    native.objc_library(
        name = name,
        hdrs = hdrs,
        srcs = srcs,
        textual_hdrs = textual_hdrs,
        data = data,
        defines = defines,
        includes = includes,
        deps = deps + additional_deps,
    )

def local_objc_grpc_library(name, deps, testing = True, srcs = [], use_well_known_protos = False, **kwargs):
    """!!For local targets within the gRPC repository only!! Will not work outside of the repo
    """
    objc_grpc_library_name = "_" + name + "_objc_grpc_library"

    generate_objc(
        name = objc_grpc_library_name,
        srcs = srcs,
        deps = deps,
        use_well_known_protos = use_well_known_protos,
        **kwargs
    )

    generate_objc_hdrs(
        name = objc_grpc_library_name + "_hdrs",
        src = ":" + objc_grpc_library_name,
    )

    generate_objc_non_arc_srcs(
        name = objc_grpc_library_name + "_non_arc_srcs",
        src = ":" + objc_grpc_library_name,
    )

    arc_srcs = None
    if len(srcs) > 0:
        generate_objc_srcs(
            name = objc_grpc_library_name + "_srcs",
            src = ":" + objc_grpc_library_name,
        )
        arc_srcs = [":" + objc_grpc_library_name + "_srcs"]

    library_deps = ["@com_google_protobuf//:protobuf_objc"]
    if testing:
        library_deps += ["//src/objective-c:grpc_objc_client_internal_testing"]
    else:
        library_deps += ["//src/objective-c:proto_objc_rpc"]

    native.objc_library(
        name = name,
        hdrs = [":" + objc_grpc_library_name + "_hdrs"],
        non_arc_srcs = [":" + objc_grpc_library_name + "_non_arc_srcs"],
        srcs = arc_srcs,
        defines = [
            "GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=0",
            "GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO=0",
        ],
        includes = ["_generated_protos"],
        deps = library_deps,
    )
