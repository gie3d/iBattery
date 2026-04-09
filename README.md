brew install gie3d/ibattery/ibattery

That single command will:

1. Add your tap automatically
2. Install libimobiledevice as a dependency
3. Build and install the ibattery binary

---

For future releases, the workflow is:

1. Make your changes and commit
2. Tag and release:
   git tag v1.1.0 && git push origin v1.1.0
   gh release create v1.1.0 --title "v1.1.0" --notes "..."
3. Get the new SHA:
   curl -sL https://github.com/gie3d/iBattery/archive/refs/tags/v1.1.0.tar.gz | shasum -a 256
4. Update Formula/ibattery.rb in homebrew-ibattery with the new url, sha256, and version — then push.
