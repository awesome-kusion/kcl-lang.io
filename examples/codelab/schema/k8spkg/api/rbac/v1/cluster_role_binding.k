"""
This is the cluster_role_binding module in kusion_kubernetes.api.rbac.v1 package.
This file was generated by the KCL auto-gen tool. DO NOT EDIT.
Editing this file might prove futile when you re-run the KCL auto-gen generate command.
"""
import k8spkg.apimachinery.apis


schema ClusterRoleBinding:
    """ ClusterRoleBinding references a ClusterRole, but not contain it.  It can reference a ClusterRole in the global namespace, and adds who information via Subject.

    Attributes
    ----------
    apiVersion : "rbac.authorization.k8s.io/v1", default is "rbac.authorization.k8s.io/v1", required
         APIVersion defines the versioned schema of this representation of an object. Servers should convert recognized schemas to the latest internal value, and may reject unrecognized values. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
    kind : "ClusterRoleBinding", default is "ClusterRoleBinding", required
         Kind is a string value representing the REST resource this object represents. Servers may infer this from the endpoint the client submits requests to. Cannot be updated. In CamelCase. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
    subjects : [Subject], default is Undefined, optional
         Subjects holds references to the objects the role applies to.
    metadata : apis.ObjectMeta, default is Undefined, optional
         Standard object's metadata.
    roleRef : RoleRef, default is Undefined, required
         RoleRef can only reference a ClusterRole in the global namespace. If the RoleRef cannot be resolved, the Authorizer must return an error.
    """


    apiVersion: "rbac.authorization.k8s.io/v1" = "rbac.authorization.k8s.io/v1"

    kind: "ClusterRoleBinding" = "ClusterRoleBinding"

    subjects?: [Subject]

    metadata?: apis.ObjectMeta

    roleRef: RoleRef


