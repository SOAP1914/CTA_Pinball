"""
tests/test_config.py

CTA PINBALL - CONFIG SMOKE TEST
================================

WHAT THIS IS
    A single, fast test that proves the entire MPF config tree parses and the
    machine actually boots into attract mode. It runs on MPF's `virtual`
    platform, so NO hardware is needed - no Neuron, no I/O boards, no Godot.

WHY IT EXISTS (CTA-specific pain this catches)
    Every one of these has cost real debugging time on this project, and every
    one of them fails this test instantly:
      * BOM corruption from PowerShell Set-Content on a config file
      * Godot rewriting an open config.yaml with tabs (never leave config.yaml
        open in the Godot editor)
      * Leading zeros eaten by the YAML parser (neuron-1-0 -> parsed as number)
      * A device referenced but never defined (typo'd switch/coil name)
      * A broken include in the _config_core.yaml manifest
      * An invalid event/option name in any mode config

    Pattern taken from Bootleggers (@bosh) tests/test_config.py.

HOW TO RUN
    From the project root, with the venv active:
        python -m pytest tests/test_config.py -v

    Run it BEFORE every commit, and ALWAYS after editing any YAML.
    It takes seconds. It has saved multi-hour sessions.

SHOW DISCIPLINE (SFGE / Expo)
    During the Week 4 freeze, this is the gate: if this test does not pass,
    do not push, and do not load the machine into the truck.
"""

from mpf.tests.MpfGameTestCase import MpfGameTestCase


class TestMachineConfig(MpfGameTestCase):
    """Boots the real CTA machine config on the virtual platform."""

    def get_config_file(self):
        # The thin entry shim that pulls in _config_core.yaml (the manifest).
        return 'config.yaml'

    def get_machine_path(self):
        # Project root: tests/ lives directly under it, so the machine path is
        # the repo root itself.
        return ''

    def get_absolute_machine_path(self):
        # Do NOT resolve relative to the installed MPF package folder - we want
        # THIS project's config, not MPF's.
        return self.get_machine_path()

    def get_platform(self):
        # No hardware required. Devices declared in config_virtual_only.yaml
        # (unwired ball lock, 3-inline drops) behave as real devices here.
        return 'virtual'

    def test_machine_enters_attract(self):
        """
        The whole point: if the config tree has ANY parse error, bad reference,
        or invalid option, MPF never reaches attract and this fails.

        One assertion, maximum coverage.
        """
        self.assertModeRunning('attract')
