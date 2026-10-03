---
folder: "python/packages/dxdj/dxdj"
generated_on: "2026-09-12"
num_files: 9
semantic_tags: [app-config, autoreload, configuration, django, package-initialization, parsing, props, routing, runtime-checking, template-components, template-engine, template-tags, typeguard, url-configuration, yaml]
todos_present: false
dependencies: []
---

# Folder Overview

## Purpose

This folder contains the top-level Python package for the DXDJ Django applications. It provides package metadata, the package-level module, and the shared URL configuration that connects administrative, scheduler, static-file, HTMX, and development-toolbar routes.

## Major Responsibilities

The package initializer exposes distribution metadata, while the URL module assembles the common `dxdj_urlpatterns` list from Django settings and the scheduler URL configuration. URL setup conditionally adds static-file routes, HTMX message handling, and the Django Debug Toolbar. The absorbed Slippers modules provide YAML component registration, runtime prop checking, custom template parsing, and component template tags. The remaining child packages contain the individual DXDJ application implementations.

## Technology Notes

This folder uses Python and Django URL configuration APIs, including `django.contrib.admin`, `django.urls`, static-file helpers, and settings-driven conditional routing.

# Folder Navigation

## Files
- `__init__.py` : Defines the top-level DXDJ package metadata, including the author, contact address, and package version.
    - Size : 239 bytes
    - Tags: [metadata, package-initialization, python]

- `dxdj.py` : Provides the package-level module and its module docstring; it contains no additional runtime implementation.
    - Size : 126 bytes
    - Tags: [module, package, python]

- `urls.py` : Builds shared Django URL patterns for administration, scheduled tasks, media, optional static-file serving, HTMX messages, and the development toolbar. Route inclusion and view selection are controlled by project settings, and missing debug-toolbar installation is handled with a warning.
    - Size : 1679 bytes
    - Tags: [django, htmx, routing, settings, urls]

- `slippers/__init__.py` : Empty package marker for the Slippers Django application.
    - Size : 0 bytes
    - Tags: [package-marker, python]

- `slippers/apps.py` : Defines `SlippersConfig`, loads component definitions from YAML files, registers component tags, and refreshes registration when configuration files change.
    - Size : 2025 bytes
    - Tags: [app-config, autoreload, component-registration, django, yaml]

- `slippers/conf.py` : Provides settings-backed accessors for Slippers runtime type checking and console or overlay output destinations.
    - Size : 718 bytes
    - Tags: [configuration, django, runtime-checking, settings]

- `slippers/merge_instructions.txt` : Documents the project-specific workflow for merging updated Django Slippers code while preserving application identity and testing through the test application.
    - Size : 695 bytes
    - Tags: [documentation, maintenance, merge-workflow, slippers]

- `slippers/props.py` : Implements the `Props` mapping, prop error records, runtime prop validation, and safe HTML serialization of component validation errors.
    - Size : 4904 bytes
    - Tags: [props, runtime-checking, typeguard, validation]

- `slippers/template.py` : Provides Django template parsing overrides for additional special characters in variable names and keyword arguments.
    - Size : 5932 bytes
    - Tags: [django, parsing, template-engine, template-syntax]

---

## Child Folders
- `attachment/docmap.md` — Attachment application implementation for file-related models, storage, and views; its folder index is pending generation.
- `dxcore/docmap.md` — Core DXDJ utilities, management commands, templates, and shared application behavior; its folder index is pending generation.
- `dxzapp/docmap.md` — DXZ application integration package; its folder index is pending generation.
- `eventsource/docmap.md` — Event-source application components and models; its folder index is pending generation.
- `htmx/docmap.md` — HTMX integration views, templates, and supporting behavior; its folder index is pending generation.
- `iam/docmap.md` — Identity and access management application components, forms, models, and templates; its folder index is pending generation.
- `iamworkflow/docmap.md` — Workflow components supporting identity and access management; its folder index is pending generation.
- `notification/docmap.md` — Notification application components and email templates; its folder index is pending generation.
- `questionaire/docmap.md` — Questionnaire application components; its folder index is pending generation.
- `rolepermissions/docmap.md` — Role and permission management, decorators, template tags, and synchronization commands; its folder index is pending generation.
- `scheduler/docmap.md` — Scheduled-task models, views, URLs, templates, and management behavior; its folder index is pending generation.
- `servers/docmap.md` — Server and deployment support components; its folder index is pending generation.
- `slippers/templates/docmap.md` — Slippers template files, including the runtime type-checking overlay; its folder index is pending generation.
- `slippers/templatetags/docmap.md` — Slippers component tags and filters for rendering, attributes, variables, matching, fragments, and runtime-error output.
- `staticfiles/docmap.md` — Package-owned static CSS and JavaScript assets; its folder index is pending generation.
- `tenantsettings/docmap.md` — Tenant-specific settings models and supporting application code; its folder index is pending generation.
- `test/docmap.md` — Internal test-support application code; its folder index is pending generation.
- `uxcomps/docmap.md` — Reusable user-experience components, templates, and supporting views; its folder index is pending generation.
- `workflow/docmap.md` — Workflow models, views, transitions, and management behavior; its folder index is pending generation.

# Related Features

This folder is the shared routing entry point for DXDJ administration, scheduled tasks, optional HTMX messaging, media and static-file delivery, and development-toolbar integration. Feature-specific behavior is implemented in the linked child applications.

# Agent Guidance

## Read When

Read this index when tracing package initialization or determining how common DXDJ URLs are assembled and enabled by settings. Follow the relevant child index for feature-specific implementation details.

## Modify When

Modify files here when package metadata, shared URL patterns, or settings-controlled route inclusion changes. Update the corresponding child index when the implementation belongs to a specific DXDJ application.

## Avoid Modifying When

Do not modify this folder for behavior owned entirely by a child application; use that application's source files and index instead.