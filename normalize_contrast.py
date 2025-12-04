"""
Script untuk menyeragamkan kontras dan brightness semua frame animasi
dengan menganalisis histogram dan menyesuaikan ke nilai median
"""

from PIL import Image, ImageStat, ImageEnhance
import os
from pathlib import Path
import statistics

# Path ke folder animasi
animation_folder = Path("assets/seaverse_animated_bg")


def calculate_image_stats(img):
    """Menghitung statistik gambar (brightness, contrast, saturation)"""
    stat = ImageStat.Stat(img)

    # Average brightness (0-255)
    brightness = sum(stat.mean) / len(stat.mean)

    # Standard deviation sebagai measure of contrast
    contrast = sum(stat.stddev) / len(stat.stddev)

    return {
        "brightness": brightness,
        "contrast": contrast,
        "mean": stat.mean,
        "stddev": stat.stddev,
    }


def analyze_all_images():
    """Analisis semua gambar untuk mendapatkan statistik"""
    stats = {}
    print("Menganalisis semua gambar...")

    for img_file in sorted(animation_folder.glob("seaverse_bg_*.jpg")):
        with Image.open(img_file) as img:
            stats[img_file.name] = calculate_image_stats(img)
            print(
                f"  ✓ {img_file.name} - Brightness: {stats[img_file.name]['brightness']:.1f}, Contrast: {stats[img_file.name]['contrast']:.1f}"
            )

    return stats


def find_target_values(stats):
    """Mencari nilai target berdasarkan median"""
    all_brightness = [s["brightness"] for s in stats.values()]
    all_contrast = [s["contrast"] for s in stats.values()]

    # Gunakan median untuk menghindari outlier
    target_brightness = statistics.median(all_brightness)
    target_contrast = statistics.median(all_contrast)

    # Atau bisa gunakan gambar dengan kontras terbaik
    # Cari gambar dengan contrast paling mendekati median dan brightness baik
    median_idx = sorted(
        range(len(all_contrast)), key=lambda i: abs(all_contrast[i] - target_contrast)
    )[len(all_contrast) // 2]

    return {
        "brightness": target_brightness,
        "contrast": target_contrast,
        "brightness_range": (min(all_brightness), max(all_brightness)),
        "contrast_range": (min(all_contrast), max(all_contrast)),
    }


def adjust_image(img, current_stats, target_values, aggressive=False):
    """Adjust brightness dan contrast gambar"""

    # Hitung factor yang diperlukan
    current_brightness = current_stats["brightness"]
    current_contrast = current_stats["contrast"]

    target_brightness = target_values["brightness"]
    target_contrast = target_values["contrast"]

    # Brightness adjustment (lebih subtle)
    brightness_factor = 1.0
    if current_brightness != 0:
        # Limit adjustment untuk menghindari perubahan drastis
        raw_factor = target_brightness / current_brightness
        if aggressive:
            brightness_factor = max(0.85, min(1.15, raw_factor))
        else:
            brightness_factor = max(0.92, min(1.08, raw_factor))

    # Contrast adjustment
    contrast_factor = 1.0
    if current_contrast != 0:
        raw_factor = target_contrast / current_contrast
        if aggressive:
            contrast_factor = max(0.85, min(1.15, raw_factor))
        else:
            contrast_factor = max(0.92, min(1.08, raw_factor))

    # Apply adjustments
    adjusted = img

    if brightness_factor != 1.0:
        enhancer = ImageEnhance.Brightness(adjusted)
        adjusted = enhancer.enhance(brightness_factor)

    if contrast_factor != 1.0:
        enhancer = ImageEnhance.Contrast(adjusted)
        adjusted = enhancer.enhance(contrast_factor)

    return adjusted, brightness_factor, contrast_factor


def process_images(stats, target_values, backup=True, aggressive=False):
    """Process semua gambar dan seragamkan kontras/brightness"""
    if backup:
        backup_folder = animation_folder.parent / "seaverse_animated_bg_contrast_backup"
        backup_folder.mkdir(exist_ok=True)
        print(f"\nMembuat backup di: {backup_folder}")

    processed = 0
    adjustments = []

    for img_file in sorted(animation_folder.glob("seaverse_bg_*.jpg")):
        with Image.open(img_file) as img:
            current_stats = stats[img_file.name]

            # Backup original
            if backup:
                backup_path = backup_folder / img_file.name
                img.save(backup_path, quality=95)

            # Adjust image
            adjusted_img, b_factor, c_factor = adjust_image(
                img, current_stats, target_values, aggressive
            )

            # Simpan hasil
            adjusted_img.save(img_file, quality=95)

            adjustments.append(
                {
                    "file": img_file.name,
                    "brightness_factor": b_factor,
                    "contrast_factor": c_factor,
                }
            )

            print(
                f"✓ {img_file.name} - Brightness: {b_factor:.3f}x, Contrast: {c_factor:.3f}x"
            )
            processed += 1

    return processed, adjustments


def main():
    print("=" * 70)
    print("SCRIPT NORMALISASI KONTRAS & BRIGHTNESS ANIMASI SEAVERSE")
    print("=" * 70)

    # Cek apakah folder ada
    if not animation_folder.exists():
        print(f"❌ Error: Folder {animation_folder} tidak ditemukan!")
        return

    # Analisis semua gambar
    print("\n1. Menganalisis statistik gambar...")
    stats = analyze_all_images()

    if not stats:
        print("❌ Error: Tidak ada gambar ditemukan!")
        return

    print(f"\n   Total gambar: {len(stats)}")

    # Hitung target values
    print("\n2. Menghitung nilai target...")
    target_values = find_target_values(stats)

    print(f"   Target Brightness: {target_values['brightness']:.1f}")
    print(
        f"   Range Brightness: {target_values['brightness_range'][0]:.1f} - {target_values['brightness_range'][1]:.1f}"
    )
    print(f"   Target Contrast: {target_values['contrast']:.1f}")
    print(
        f"   Range Contrast: {target_values['contrast_range'][0]:.1f} - {target_values['contrast_range'][1]:.1f}"
    )

    # Tanya mode adjustment
    print("\n3. Mode adjustment:")
    print("   - Normal: Adjustment subtle (±8%)")
    print("   - Aggressive: Adjustment lebih kuat (±15%)")
    mode = (
        input("   Pilih mode [normal/aggressive] (default: normal): ").strip().lower()
    )
    aggressive = mode == "aggressive"

    # Konfirmasi
    print(
        f"\n4. Memproses gambar (Mode: {'Aggressive' if aggressive else 'Normal'})..."
    )
    print("   (Backup akan disimpan di folder seaverse_animated_bg_contrast_backup)")

    # Process
    processed, adjustments = process_images(
        stats, target_values, backup=True, aggressive=aggressive
    )

    print("\n" + "=" * 70)
    print("SELESAI!")
    print(f"✓ Diproses: {processed} gambar")

    # Statistik adjustment
    b_factors = [a["brightness_factor"] for a in adjustments]
    c_factors = [a["contrast_factor"] for a in adjustments]

    print(f"\nStatistik Adjustment:")
    print(
        f"  Brightness: {min(b_factors):.3f}x - {max(b_factors):.3f}x (avg: {statistics.mean(b_factors):.3f}x)"
    )
    print(
        f"  Contrast: {min(c_factors):.3f}x - {max(c_factors):.3f}x (avg: {statistics.mean(c_factors):.3f}x)"
    )
    print("=" * 70)

    # Verifikasi
    print("\n5. Verifikasi hasil...")
    stats_after = analyze_all_images()
    target_after = find_target_values(stats_after)

    print(
        f"\n   Brightness range setelah: {target_after['brightness_range'][0]:.1f} - {target_after['brightness_range'][1]:.1f}"
    )
    print(
        f"   Contrast range setelah: {target_after['contrast_range'][0]:.1f} - {target_after['contrast_range'][1]:.1f}"
    )

    # Hitung improvement
    brightness_range_before = (
        target_values["brightness_range"][1] - target_values["brightness_range"][0]
    )
    brightness_range_after = (
        target_after["brightness_range"][1] - target_after["brightness_range"][0]
    )
    contrast_range_before = (
        target_values["contrast_range"][1] - target_values["contrast_range"][0]
    )
    contrast_range_after = (
        target_after["contrast_range"][1] - target_after["contrast_range"][0]
    )

    print(f"\n   Improvement:")
    print(
        f"   - Brightness variance: {brightness_range_before:.1f} → {brightness_range_after:.1f} ({(1 - brightness_range_after / brightness_range_before) * 100:.1f}% lebih seragam)"
    )
    print(
        f"   - Contrast variance: {contrast_range_before:.1f} → {contrast_range_after:.1f} ({(1 - contrast_range_after / contrast_range_before) * 100:.1f}% lebih seragam)"
    )


if __name__ == "__main__":
    main()
