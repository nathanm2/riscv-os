
fn main() {
    println!("cargo:rerun-if-changed=src/lds/virt.lds");
    println!("cargo:rustc-link-arg=-Tsrc/lds/virt.lds");
}
