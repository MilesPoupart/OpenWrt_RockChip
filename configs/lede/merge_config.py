#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys

def parse_config(file_path):
    """
    解析配置文件，将配置项存入字典。
    处理以下情况：
    - 空行和普通注释行会被忽略，除非是类似 "# CONFIG_XYZ is not set" 的行。
    - CONFIG_XYZ=y, CONFIG_XYZ=m, CONFIG_XYZ=n
    - # CONFIG_XYZ is not set 被视为 CONFIG_XYZ=n
    """
    config = {}
    try:
        with open(file_path, 'r') as f:
            for line in f:
                stripped = line.strip()
                if not stripped:
                    continue  # 忽略空行
                if stripped.startswith("#"):
                    # 处理 "# CONFIG_XYZ is not set" 这种格式
                    if stripped.startswith("# CONFIG_") and " is not set" in stripped:
                        key = stripped[2:].split(" is not set")[0].strip()
                        config[key] = 'n'
                    continue  # 忽略其他注释行
                if "=" in stripped:
                    key, value = stripped.split('=', 1)
                    key = key.strip()
                    value = value.strip()
                    # if value in ["y", "m", "n"]:
                    config[key] = value
    except FileNotFoundError:
        print(f"文件未找到: {file_path}")
        sys.exit(1)
    except Exception as e:
        print(f"读取文件时出错: {file_path}\n错误信息: {e}")
        sys.exit(1)
    return config

def merge_configs(config1, config2):
    """
    合并两个配置字典。
    - 对于只在一个字典中存在的键，直接保留其值。
    - 对于两个字典中都存在的键：
        - 如果值相同，保留该值。
        - 如果值不同，提示用户选择保留哪个值。
    返回合并后的字典。
    """
    merged = {}
    keys = set(config1.keys()).union(set(config2.keys()))
    conflicts = []
    
    for key in sorted(keys):
        val1 = config1.get(key)
        val2 = config2.get(key)
        
        if val1 and not val2:
            merged[key] = val1
        elif val2 and not val1:
            merged[key] = val2
        elif val1 and val2:
            if val1 == val2:
                merged[key] = val1
            else:
                # 冲突处理
                print(f"\n配置冲突: {key}")
                print(f"1. {format_config_line(key, val1)}")
                print(f"2. {format_config_line(key, val2)}")
                choice = input("请选择要保留的配置 (1 或 2): ").strip()
                while choice not in ['1', '2']:
                    choice = input("输入无效。请选择 1 或 2: ").strip()
                merged[key] = val1 if choice == '1' else val2
    return merged

def format_config_line(key, value):
    """
    根据值格式化输出配置行。
    - y 或 m: CONFIG_XYZ=y 或 CONFIG_XYZ=m
    - n: # CONFIG_XYZ is not set
    """
    if value != 'n':
        return f"{key}={value}"
    elif value == 'n':
        return f"# {key} is not set"

def write_merged_config(merged, output_path):
    """
    将合并后的配置写入输出文件，按字典序排序。
    将值为 'n' 的配置项格式化为注释行。
    """
    try:
        with open(output_path, 'w') as f:
            for key in sorted(merged.keys()):
                line = format_config_line(key, merged[key])
                f.write(line + '\n')
        print(f"\n合并后的配置已写入: {output_path}")
    except Exception as e:
        print(f"写入文件时出错: {output_path}\n错误信息: {e}")
        sys.exit(1)

def compare_configs(new_config_path, existing_config_path):
    """
    比较 merged_new.config 与 merged.config 的差异。
    列出所有冲突项，提示用户进行人工处理。
    """
    def load_config(file_path):
        return parse_config(file_path)
    
    new_config = load_config(new_config_path)
    existing_config = load_config(existing_config_path)
    
    conflicts = {}
    all_keys = set(new_config.keys()).union(set(existing_config.keys()))
    
    for key in all_keys:
        new_val = new_config.get(key)
        existing_val = existing_config.get(key)
        if new_val and existing_val and new_val != existing_val:
            conflicts[key] = (new_val, existing_val)
    
    if conflicts:
        print("\n与现有 merged.config 存在以下冲突项，需要人工处理:")
        for key, (new_val, existing_val) in conflicts.items():
            print(f"\n配置项: CONFIG_{key}")
            print(f"merged_new.config: {format_config_line(key, new_val)}")
            print(f"merged.config: {format_config_line(key, existing_val)}")
        print("\n请手动编辑 merged_new.config 以解决这些冲突，然后重新运行脚本或按下回车继续。")
        input("人工处理完成后，按 Enter 键继续...")
    else:
        print("\nmerged_new.config 与现有的 merged.config 无冲突。")

def main():
    # 定义文件路径
    base_dir = "/Users/milespoupart/gitspace/OpenWrt_RockChip/configs/lede"
    file1 = os.path.join(base_dir, "empty.config")
    file2 = os.path.join(base_dir, "lite.config")
    output = os.path.join(base_dir, "lite_new.config")
    existing_merged = os.path.join(base_dir, "full.config")
    
    # 解析配置文件
    print("正在解析配置文件...")
    config1 = parse_config(file1)
    config2 = parse_config(file2)
    
    # 合并配置
    print("\n正在合并配置文件...")
    merged = merge_configs(config1, config2)
    
    # 写入合并后的配置
    write_merged_config(merged, output)
    
    # 比较与现有 merged.config 的差异
    # if os.path.exists(existing_merged):
    #     compare_configs(output, existing_merged)
    # else:
    #     print(f"\n不存在现有的 merged.config 文件: {existing_merged}")
    #     print("跳过比较步骤。")

if __name__ == "__main__":
    main()